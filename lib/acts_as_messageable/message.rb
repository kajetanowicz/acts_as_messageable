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

    
    #for some reason doing  scope :deleted , ...  causes problems
    def self.deleted
      where("recipient_delete = ? or sender_delete = ?" , true , true )
    end
    
    
    def open
      self.opened = true
    end

    def from
      self.sent_messageable
    end

    def to
      self.received_messageable
    end

  end
end
