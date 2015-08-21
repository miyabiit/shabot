# Scaffolding generated by Casein v5.1.1.5

module Casein
  class ReportsController < Casein::CaseinController
  
    ## optional filters for defining usage according to Casein::AdminUser access_levels
    # before_filter :needs_admin, :except => [:action1, :action2]
    # before_filter :needs_admin_or_current_user, :only => [:action1, :action2]
  
    def index
      @casein_page_title = 'Reports'
  		@reports = Report.order(sort_order(:name)).paginate :page => params[:page]
    end
  
		def pdf_list
      payment_headers = PaymentHeader.all
			pdf = PaymentList.new(payment_headers)
			send_data pdf.render,
				filename:	"payment-list.pdf",
				type:			"application/pdf",
				disposition:	"inline"
		end

		def pdf_monthly
      payment_headers = PaymentHeader.all
			pdf = PaymentReport.new(payment_headers)
			send_data pdf.render,
				filename:	"payment-monthly.pdf",
				type:			"application/pdf",
				disposition:	"inline"
		end

    def show
      @casein_page_title = 'View report'
      @report = Report.find params[:id]
    end
  
    def new
      @casein_page_title = 'Add a new report'
    	@report = Report.new
    end

    def create
      @report = Report.new report_params
    
      if @report.save
        flash[:notice] = 'Report created'
        redirect_to casein_reports_path
      else
        flash.now[:warning] = 'There were problems when trying to create a new report'
        render :action => :new
      end
    end
  
    def update
      @casein_page_title = 'Update report'
      
      @report = Report.find params[:id]
    
      if @report.update_attributes report_params
        flash[:notice] = 'Report has been updated'
        redirect_to casein_reports_path
      else
        flash.now[:warning] = 'There were problems when trying to update this report'
        render :action => :show
      end
    end
 
    def destroy
      @report = Report.find params[:id]

      @report.destroy
      flash[:notice] = 'Report has been deleted'
      redirect_to casein_reports_path
    end
  
    private
      
      def report_params
        params.require(:report).permit(:name, :filename)
      end

  end
end