class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  # Add the status attribute
  enum status: { unread: 0, read: 1 ,unapproved:2} # You can use 'unread' and 'read' or any other statuses you need
end
