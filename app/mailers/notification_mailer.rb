class NotificationMailer < ApplicationMailer
    default from: "homecourierfing@gmail.com"

    def order_new_postulations_email
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: "Se han postulado al pedido '#{@order.title}'")
    end
    def order_accepted_email
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: "Fue elegido para el pedido '#{@order.title}'")
    end
    def order_in_process_email
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: "Su pedido está en proceso")
    end
    def order_finished_email
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: "Su pedido ha terminado")
    end
    def order_cancelled_email
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: "Su pedido fue cancelado")
    end
end
