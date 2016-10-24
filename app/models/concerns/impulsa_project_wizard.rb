module ImpulsaProjectWizard
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations::SpanishVatValidatorsHelpers
    include ActiveModel::Validations::EmailValidatorHelpers

    store :wizard_values, coder: YAML

    before_create do
      self.wizard_step = self.wizard_steps.keys.first
    end

    EXTENSIONS = {
      xls: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      xlsx: "application/vnd.ms-excel",
      pdf: "application/x-pdf"
    }
    FILETYPES = {
      sheet: [:xls, :xlsx],
      image: [:jpg, :png, :gif],
      pdf: [:pdf]
    }
    MAX_FILE_SIZE = 1024*1024*10

    def wizard
      impulsa_edition_category.wizard
    end

    def wizard_steps
      ret = Hash[wizard.map {|sname, step| [sname, step[:title]]}]
      #ret["compartir"] = "Compartir"
      ret
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
          filled = false if sname == wizard_step
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

    def wizard_step_fields
      _all = wizard[wizard_step][:groups].map do |gname,group|
        group[:fields].map do |fname, field|
          ["_wiz_#{gname}__#{fname}", field[:type]=="check_boxes"]
        end
      end .flatten(1)
      _all.collect{|field, multiple| field unless multiple}.compact + [Hash[_all.select(&:last).map{|field,multiple| [field, []]}]]
    end

    def wizard_has_errors?
      wizard.any? do |sname, step|
        wizard_step_errors(sname).any?
      end
    end

    def wizard_valid?
      wizard_step_errors.each do |field, error|
        errors.add(field, error)
      end .none?
    end

    def wizard_step_errors step = nil
      wizard[step || wizard_step][:groups].map do |gname,group|
        group[:fields].map do |fname, field|
          [ "_wiz_#{gname}__#{fname}", wizard_field_error(gname, fname, group, field) ]
        end.select(&:last)
      end.flatten(1)
    end

    def wizard_eval_condition group
      group[:condition].blank? || eval(group[:condition])
    end

    def wizard_field_error gname, fname, group = nil, field = nil
      group = wizard.collect {|sname, step| step[:groups][gname] } .compact.first if group.nil?
      return nil if !wizard_eval_condition(group)
      field = group[:fields][fname] if field.nil?
      value = wizard_values["#{gname}.#{fname}"]
      return "no es un campo" if field.nil?
      return "es obligatorio" if value.blank? && !field[:optional]
      return "no es un NIF correcto" if field[:format]=="nif" && !validate_nif(value)
      return "no es un CIF correcto" if field[:format]=="cif" && !validate_cif(value)
      return "no es un NIE correcto" if field[:format]=="nie" && !validate_nie(value)
      return "no es un DNI o NIE correcto" if field[:format]=="dninie" && !(validate_nif(value) || validate_nie(value))
      error = validate_email(value) if field[:format]=="email"
      return error if error
      nil
    end

    def assign_wizard_value gname, fname, value
      field = wizard.map {|sname, step| step[:groups][gname] && step[:groups][gname][:fields][fname] } .compact.first
      if field
        if field[:type] == "file"
          old_name = wizard_values["#{gname}.#{fname}"]
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
          File.delete(File.join(files_folder, old_name)) if old_name && old_name != file
        else
          wizard_values["#{gname}.#{fname}"] = value
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
      else
        super
      end
    end
 
  end
end