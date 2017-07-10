class VisitRequest
  class Cancel < ApplicationService
    def initialize(visit_request)
      @visit_request = visit_request
    end

    def call
      visit_request.canceled!
      attend_first_user_from_waitlist
    end

    private

    attr_reader :visit_request

    def attend_first_user_from_waitlist
      if waiting_list_request = VisitRequest.where(waiting_list: true).first
        waiting_list_request.waiting_list = false
        waiting_list_request.save
        if visit_request.event.status == 'registration'
          VisitRequest::Approve.call(waiting_list_request)
        else
          VisitRequest::FinalConfirmation(waiting_list_request)
        end
      end
    end
  end
end
