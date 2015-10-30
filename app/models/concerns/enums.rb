require 'active_support/concern'
module Enums
  extend ActiveSupport::Concern

  included do
    enum status: [:active, :archived]
  end
end
