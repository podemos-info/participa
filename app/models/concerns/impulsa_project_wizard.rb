module ImpulsaProjectWizard
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations::SpanishVatValidatorsHelpers
    include ActiveModel::Validations::EmailValidatorHelpers

    store :wizard_values, coder: YAML 
    store :wizard_review, coder: YAML

    before_create do
      self.wizard_step = self.wizard_steps.keys.first
    end

    EXTENSIONS = {
      doc: "application/msword",
      docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      jpg: "image/jpeg",
      ods: "application/vnd.oasis.opendocument.spreadsheet",
      odt: "application/vnd.oasis.opendocument.text",
      pdf: "application/pdf",
      xls: "application/vnd.ms-excel",
      xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    }
    FILETYPES = {
      sheet: [:xls, :xlsx, :ods],
      scan: [:jpg, :pdf],
      document: [:doc, :docx, :odt]
    }
    MAX_FILE_SIZE = 1024*1024*10

    def wizard
      impulsa_edition_category.wizard
    end

    def wizard_steps
      Hash[wizard.map {|sname, step| [sname, step[:title]]}]
    end

    def wizard_next_step
      wizard.keys[wizard.keys.find_index(wizard_step)+1]
    end

    def wizard_step_info
      wizard[wizard_step]
    end

    def wizard_status
      @wizard_status ||= begin
        filled = true
        ret = wizard.map do |sname, step|
          filled = false if sname == wizard_step_was
          fields = values = errors = 0
          step[:groups].each do |gname,group| 
            group[:fields].each do |fname, field|
              fields += 1
              values += 1 if wizard_values["#{gname}.#{fname}"].present?
              errors += 1 if wizard_field_error(gname, fname, group, field)
            end
          end
          { step: sname, title: step[:title], fields: fields, values: values, errors: errors, filled: filled }
        end
        last_filled = ret.rindex {|step| step[:values]>0 }
        (0..last_filled).each do |i|
          ret[i][:filled] = true
        end unless last_filled.nil?
        Hash[ret.map {|step|
          [ step[:step], step ]
        }]
      end
    end

    def wizard_step_admin_params
      _all = wizard.map do |sname, step|
        step[:groups].map do |gname,group|
          group[:fields].map do |fname, field|
            ["_wiz_#{gname}__#{fname}", field[:type]=="check_boxes"]
          end .compact
        end .flatten(1)
      end .flatten(1)
      _all.collect{|field, multiple| field unless multiple}.compact + [Hash[_all.select(&:last).map{|field,multiple| [field, []]}]]
    end

    def wizard_step_params
      _all = wizard[wizard_step][:groups].map do |gname,group|
        group[:fields].map do |fname, field|
          ["_wiz_#{gname}__#{fname}", field[:type]=="check_boxes"] if self.wizard_editable_field?(gname, fname) 
        end .compact
      end .flatten(1)
      _all.collect{|field, multiple| field unless multiple}.compact + [Hash[_all.select(&:last).map{|field,multiple| [field, []]}]]
    end

    def wizard_editable_field? gname, fname
      self.editable? || (self.fixable? && (self.wizard_review["#{gname}.#{fname}"].present? || self.wizard_field_error(gname,fname)))
    end
    
    def wizard_has_errors? options = {}
      wizard_count_errors(options) > 0
    end      

    def wizard_count_errors options = {}
      wizard.sum do |sname, step|
        wizard_step_errors(sname, options).count
      end
    end

    def wizard_valid?
      wizard_step_errors.each do |field, error|
        errors.add(field, error)
      end .none?
    end

    def wizard_step_errors step = nil, options = {}
      wizard[step || wizard_step][:groups].map do |gname,group|
        group[:fields].map do |fname, field|
          [ "_wiz_#{gname}__#{fname}", wizard_field_error(gname, fname, group, field, options) ]
        end.select(&:last)
      end.flatten(1)
    end

    def wizard_eval_condition group
      group[:condition].blank? || eval(group[:condition])
    end

    def wizard_field_error gname, fname, group = nil, field = nil, options = {}
      group = wizard.collect {|sname, step| step[:groups][gname] } .compact.first if group.nil?
      return nil if !wizard_eval_condition(group)
      field = group[:fields][fname] if field.nil?
      value = wizard_values["#{gname}.#{fname}"]
      return "no es un campo" if field.nil?
      return "es obligatorio" if value.blank? && !field[:optional]
      if value.present?
        return "debe ser aceptado" if value!="1" && field[:format]=="accept"
        return "puede tener hasta #{field[:limit]} caracteres" if field[:limit] && value.length>field[:limit]
        return "no es un NIF correcto" if field[:format]=="cif" && !validate_cif(value)
        return "no es un DNI correcto" if field[:format]=="dni" && !validate_nif(value)
        return "no es un NIE correcto" if field[:format]=="nie" && !validate_nie(value)
        return "no es un DNI o NIE correcto" if field[:format]=="dninie" && !(validate_nif(value) || validate_nie(value))
        return "no es un teléfono válido" if field[:format]=="phone" && Phonelib.parse(value).valid?
        return "no es una dirección web válida" if field[:type]=="url" && URI::regexp(%w(http https)).match(value).nil?
        return "debes seleccionar al menos #{field[:minimum]} opciones" if field[:type]=="check_boxes" && field[:minimum] && value.count<field[:minimum]
        return "puedes seleccionar hasta #{field[:maximum]} opciones" if field[:type]=="check_boxes" && field[:maximum] && value.count>field[:maximum]
        error = validate_email(value) if field[:type]=="email"
        return error if error
      end
      return self.wizard_review["#{gname}.#{fname}"] if (options[:ignore_state] || self.fixable?) && self.wizard_review["#{gname}.#{fname}"].present? && self.wizard_review["#{gname}.#{fname}"][0] != "*"
      nil
    end

    def assign_wizard_value gname, fname, value
      field = wizard.map {|sname, step| step[:groups][gname] && step[:groups][gname][:fields][fname] } .compact.first
      if field
        old_value = wizard_values["#{gname}.#{fname}"]
        if field[:type] == "file"
          file = "#{gname}.#{fname}"
          if value.present?
            ext = File.extname(value.path)
            return :wrong_extension if field[:filetype] && !(FILETYPES[field[:filetype].to_sym]||[]).member?(ext[1..-1].to_sym)
            return :wrong_size if value.size > (field[:maxsize] || MAX_FILE_SIZE)
            file += ext
            FileUtils.mkdir_p(files_folder)
            File.open(File.join(files_folder, file), "wb") { |f| f.write(value.read) }
            wizard_values["#{gname}.#{fname}"] = file
          else
            wizard_values["#{gname}.#{fname}"] = nil
          end
          File.delete(File.join(files_folder, old_value)) if old_value && old_value != file
        elsif field[:type] == "check_boxes"
          wizard_values["#{gname}.#{fname}"] = value.select(&:present?)
        else
          wizard_values["#{gname}.#{fname}"] = value
        end

        if old_value!=value && self.fixable? && self.wizard_review["#{gname}.#{fname}"].present? && self.wizard_review["#{gname}.#{fname}"][0]!="*"
          self.wizard_review["#{gname}.#{fname}"] = "*" + self.wizard_review["#{gname}.#{fname}"]
        end  
        return :ok
      end
      return :wrong_field
    end

    def wizard_path gname, fname
      files_folder + wizard_values["#{gname}.#{fname}"]
    end

    def method_missing(method_sym, *arguments, &block)
      if method_sym.to_s =~ /^_wiz_(.+)__([^=]+)=?$/
        self.instance_eval <<-RUBY
          def _wiz_#{$1}__#{$2}
            wizard_values["#{$1}.#{$2}"]
          end
          def _wiz_#{$1}__#{$2}= value
            assign_wizard_value(:"#{$1}", :"#{$2}", value)
          end
        RUBY
        send(method_sym, *arguments)
      elsif method_sym.to_s =~ /^_rvw_(.+)__([^=]+)=?$/
        self.instance_eval <<-RUBY
          def _rvw_#{$1}__#{$2}
            wizard_review["#{$1}.#{$2}"]
          end
          def _rvw_#{$1}__#{$2}= value
            wizard_review["#{$1}.#{$2}"] = value
          end
        RUBY
        send(method_sym, *arguments)
      else
        super
      end
    end
 
  end
end