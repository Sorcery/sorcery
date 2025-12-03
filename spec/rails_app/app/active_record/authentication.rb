# frozen_string_literal: true

class Authentication < ActiveRecord::Base
  belongs_to :user
end
