class RootController < ApplicationController
  def index
    @games = self.class.instance_methods(false).reject{|name| name =~ /^_/ || name == :index }
  end

  def breakout
  end
end
