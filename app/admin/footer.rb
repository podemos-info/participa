module ActiveAdmin
  module Views
    class Footer < Component

      def build
        super :id => "footer"                                                    
        super :style => "text-align: right;"                                     

        div do                                                                   
          small do
            link_to "Leer Aviso Legal", "/pdf/aviso_legal.pdf", target: "_blank"
          end
        end
      end

    end
  end
end
