class Flora < ActiveRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :related_floras, with: :flora_relationships
  relates :magics, with: :flora_magical_effects
  relates :locations, with: :flora_locations
  relates :creatures, with: :flora_eaten_by

  def self.content_name
    'flora'
  end

  def self.color
    'text-lighten-3 lighten-3 teal'
  end

  def self.icon
    'local_florist'
  end
end
