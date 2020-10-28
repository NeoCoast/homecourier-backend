class NotificationMailer < ApplicationMailer
    default from: "homecourierfing@gmail.com"

    def order_accepted_email(user, order)
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: 'Su pedido ha sido aceptado')
    end
    def order_in_process_email(user, order)
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: 'Su pedido está en proceso')
    end
    def order_finished_email(user, order)
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: 'Su pedido ha terminado')
    end
    def order_cancelled_email(user, order)
        @user = params[:user]
        @order = params[:order]
        mail(to: @user.email, subject: 'Su pedido fue cancelado')
    end
end
