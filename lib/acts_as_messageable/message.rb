module ActsAsMessageable
  class Message < ::ActiveRecord::Base
    belongs_to :received_messageable, :polymorphic => true
    belongs_to :sent_messageable, :polymorphic => true

    attr_accessible :topic,
                    :body,
                    :received_messageable_type,
                    :received_messageable_id,
                    :sent_messageable_type,
                    :sent_messageable_id,
                    :opened

    validates_presence_of :topic ,:body

    
    scope :deleted , where("recipient_delete = ? or sender_delete = ?" , true , true )
    
    def open
      self.opened = true
    end

    def from
      sent_messageable
    end

    def to
      received_messageable
    end

  end
end
