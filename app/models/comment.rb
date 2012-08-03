class Comment
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # For now this list is a hardcoded constant. Eventually it might be more flexible
  # as more thought is put into the process of providing a comment
  SUBJECTS = ["General feedback", "Request for access", "Technical support", "Other"]
  
  attr_accessor :name, :subject, :email, :nickname

  validates :name, 
    presence: {message: "Name is a required field"}
  validates :subject, inclusion: 
    { in: SUBJECTS, 
      message: "Choose a subject from the dropdown menu" }
  # Use a third party library to keep up with changes instead of a brittle regular
  # expression that has to be tested / reviewed from time to time
  validates :email, 
    confirmation: {message: "Email addresses do not match"},
    #email: {message: "Email address is not valid"},
    presence: {message: "Email address is a required field"}
  validates :comment, 
    presence: { message: "Provide a comment before submitting the form"}
    
  # The nickname should be empty since it is a captcha designed to prevent spam
  # Thus there is no error message because there is no way for a person to submit
  # the form with a value
  validates :nickname, 
    length: {is: 0, message: nil}
  
  def comment
    @comment
  end
  
  def comment=(new_comment)
    # By default prune out all tags. It might be worth thinking about other approaches
    # supported by Loofah (see https://github.com/flavorjones/loofah)
    @comment = Loofah.scrub_fragment(new_comment, :prune).to_s
    puts "<< After : #{@comment} >>"
  end
  
  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v)
    end
  end
  
  # Stub this method out so that form_for functions as expected even though there is
  # no database backing the Comment model
  def persisted?
    false
  end
  
  def spam?
    # TODO : Stub out a method for verifying that it is not spam beyond this basic
    #        test
    return (not @nickname.nil?)
  end
end