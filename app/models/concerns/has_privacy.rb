require 'active_support/concern'

module HasPrivacy
  extend ActiveSupport::Concern

  included do
    scope :is_public, -> do
      # self is an AR relation, so we use klass to get the class of the relation model
      if self.klass == Universe
        where(privacy: 'public')
      else
        eager_load(:universe).where("#{self.name.pluralize}.privacy = ? OR universes.privacy = ?", 'public', 'public')
      end
    end

    def private_content?
      !public_content?
    end

    def public_content?
      universe_is_public = respond_to?(:universe) && universe.present? && universe.public_content?
      privacy == 'public' || universe_is_public
    end
  end
end
