class WelcomeController < ApplicationController
  def index
    @kntn = Kntn.new
  end
end
