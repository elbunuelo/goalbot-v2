# frozen_string_literal: true

module Redd
  module Models
    # Things that can be sent to a user's inbox.
    module Inboxable
      # Block the user that sent this item.
      def block
        client.post('/api/block', id: read_attribute(:name))
      end

      # Collapse the item.
      def collapse
        client.post('/api/collapse_message', id: read_attribute(:name))
      end

      # Uncollapse the item.
      def uncollapse
        client.post('/api/uncollapse_message', id: read_attribute(:name))
      end

      # Mark this thing as read.
      def mark_as_read
        client.post('/api/read_message', id: read_attribute(:name))
      end

      # Mark one or more messages as unread.
      def mark_as_unread
        client.post('/api/unread_message', id: read_attribute(:name))
      end
    end
  end
end
