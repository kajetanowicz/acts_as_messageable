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
      def acts_as_messageable options = {}
        options[:dependent] ||= :nullify
        class_eval do
          has_many :recv, :as => :received_messageable  , :class_name => "ActsAsMessageable::Message" , :dependent => options[:dependent]
          has_many :sent, :as => :sent_messageable      , :class_name => "ActsAsMessageable::Message" , :dependent => options[:dependent]
          include ActsAsMessageable::User::InstanceMethods
        end        
      end
    end  
    

    module InstanceMethods
      def messages
        ActsAsMessageable::Message.where("(sent_messageable_type = ? and sent_messageable_id = ? ) or (received_messageable_type = ? and received_messageable_id = ?)" , self.class.name , self.id ,  self.class.name , self.id )
      end
      
      def from_messages from
        messages.where :sent_messageable_id => from.id , :sent_messageable_type => from.name
      end
      
      
      def to_messages to
        messages.where :received_messageable_id => to.id , :received_messageable_type => to.name
      end
      
      def send_msg(to, topic, body)                 
        @message = self.sent.build(:topic => topic, :body => body)
        to.recv  << @message
        raise ActsAsMessageable::MessageInvalid.new(@message) if @message.invalid?         
      end
    end
    
  end
end
