module ActsAsMessageable
  
  class MessageInvalid < StandardError 
    
    attr_accessor :message
  
    def initialize(invalid_msg , msg = nil)
      super msg
      @message = invalid_msg
    end
  
  end
  
  module User

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_messageable
      class_eval do
        has_many :recv, :as => :received_messageable  , :class_name => "ActsAsMessageable::Message" , :dependent => :nullify
        has_many :sent, :as => :sent_messageable      , :class_name => "ActsAsMessageable::Message" , :dependent => :nullify        
      end

      include ActsAsMessageable::User::InstanceMethods
    end
      
    end

    module InstanceMethods
      def messages
        self.recv + self.sent
      end
      
      def from_messages from
        messages.where :sent_messageable_id => from.id , :sent_messageable_type => from.name
      end
      
      
      def to_messages to
        messages.where :received_messageable_id => to.id , :received_messageable_type => to.name
      end
      
    end



      def send_msg(to, topic, body)         
        
        @message = to.recv  << self.sent.build  :topic => topic, :body => body
        raise ActsAsMessageable::MessageInvalid.new(@message) if @message.invalid?         
      end

    end

  end
end
