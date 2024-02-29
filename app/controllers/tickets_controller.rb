class TicketsController < ApplicationController 
    def generate
        if (params[:service].blank? || params[:order].blank?) || (params[:service].blank? && params[:order].blank?) 
            
            @message = 'Please provide parameter values !'
            @status = 400
            @link = nil
           
        else  

            receipt = File.file? Rails.root.join('public','pdfs', "#{params[:service]}", "#{params[:order]}.pdf")
            if receipt 
                @message = 'Receipt already generated'
                @status = 200
                @link = "#{ENV['APP_URL']}/pdfs/#{params[:service]}/#{params[:order]}.pdf"
            else
                request = TransactionService.call params
                if request.status == 200
                    payload = { service: params[:service], order: params[:order], data: request.response }
                    PdfBuilderCommand.call payload
                    @message = 'Receipt generated with succes'
                    @status = 200
                    @link = "#{ENV['APP_URL']}/pdfs/#{params[:service]}/#{params[:order]}.pdf"     
                else
                    @status = 400
                    @message = 'Invalid order!'
                    @link = nil
                end
            end 
        end
       
        render json: { status: @status, message: @message, link: @link }
    end
end