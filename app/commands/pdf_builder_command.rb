require 'prawn-html'
class PdfBuilderCommand < ApplicationCommand 
    attr_reader :params

    def initialize params 
        @params = params
    end

    def call 
        @data = params[:data]
        template = open("#{Rails.root}/app/views/receipts/#{params[:service]}/pdf.html.erb", 'r') { |f| f.read }
        content = ERB.new(template).result(binding)
        pdf = Prawn::Document.new(page_size: 'A4')
        PrawnHtml.append_html(pdf, content)
        pdf.render_file("#{pdf_repository}/#{params[:order]}.pdf")
    end


   private 

   def pdf_repository
    {
        'oneci' => "#{Rails.root.join('public', 'pdfs', 'oneci')}"
    }.fetch(params[:service])
   end
end