namespace :data_migrations do
  desc "Create activators for all used content types for all users"
  task create_content_type_activators: :environment do
    default_content_types = [
      Universe, Character, Location, Item
    ]
    variable_content_types = [
      Creature, Flora, Group, Language, Magic, Race, Religion, Scene
    ]

    User.where('id > 20000').find_each do |user|
      puts "Creating activators for user #{user.id}" if (user.id % 1000).zero?

      # These are default, but users can turn them off later
      default_content_types.each do |content_type|
        user.user_content_type_activators.find_or_create_by(content_type: content_type.name)
      end

      # Only turn these ones on if users have any existing content for them
      variable_content_types.each do |content_type|
        existing_content = user.send(content_type.name.downcase.pluralize).count > 0

        if existing_content
          user.user_content_type_activators.find_or_create_by(content_type: content_type.name)
        end
      end
    end
  end

  desc "Migrate to the new attributes system"
  task migrate_all_users_to_new_attributes: :environment do
    User.find_each do |user|
      puts "Migrating user #{user.id}"

      # If this user has any content with no universe, create a universe and put
      # that content in it.
      orphan_content = user.content_without_universe
      if orphan_content.values.flatten.compact.any?
        universe = user.universes.create(name: 'Untitled')

        orphan_content.each do |klass, orphan_list|
          orphan_list.update_all(universe_id: universe.id)
        end
      end

      # Now that the user is guaranteed to have at least one universe, we want to
      # create default categories/fields for each of their universes.
      user.universes.each do |universe|
        content_classes = Rails.application.config.content_types[:all_non_universe]
        content_classes.each do |content_class|
          content_class.create_default_page_categories_and_fields!(universe)
        end
      end
    end
  end

  desc "Initialize Stripe customer ID for all users without one already"
  task initialize_stripe_customers: :environment do
    User.where(stripe_customer_id: nil).each do |user|
      puts "Initializing Stripe Customer for user #{user.email.split('@').first}@"
      user.initialize_stripe_customer
    end
  end

  desc "Add a billing plan for all users that don't already have one"
  task create_default_billing_plans: :environment do
    # todo: Grab the actual promised date/time here
    BETA_TESTERS_CUTOFF_DATE = "2016-11-01 08:00:00".to_time # October 1 through November 1, 2016, with 8 hours wiggle room

    User.where(selected_billing_plan_id: nil).each do |user|
      puts "Setting default billing plan for #{user.email.split('@').first}@"

      beta_testers_plan  = BillingPlan.find_by(stripe_plan_id: 'free-for-life')
      standard_free_tier = BillingPlan.find_by(stripe_plan_id: 'starter')

      if beta_testers_plan.nil? || standard_free_tier.nil?
        raise "Couldn't find one of the necessary plans for this task -- check for free-for-life and starter stripe plan IDs"
      end

      if user.created_at < BETA_TESTERS_CUTOFF_DATE
        # If the user was created before the free-for-life beta testers promo, give them that plan
        puts "\tAdding to BETA TESTERS plan."
        user.update(selected_billing_plan_id: beta_testers_plan.id)
      else
        # Otherwise, give the user the default free plan
        puts "\tAdding to FREE TIER plan."
        user.update(selected_billing_plan_id: standard_free_tier.id)
      end

      # Since no active subscriptions is equivalent to the free tier, there's no need to build Subscriptions for these users
    end
  end

  desc "Add bandwidth bonuses to billing plans"
  task billing_plan_bandwidths: :environment do
    puts "Updating bandwidths for all billing plans"
    BillingPlan.find_by(stripe_plan_id: 'starter').update(bonus_bandwidth_kb: 50_000)
    BillingPlan.find_by(stripe_plan_id: 'free-for-life').update(bonus_bandwidth_kb: 250_000)
    BillingPlan.find_by(stripe_plan_id: 'early-adopters').update(bonus_bandwidth_kb: 950_000)
    BillingPlan.find_by(stripe_plan_id: 'premium').update(bonus_bandwidth_kb: 950_000)
    puts "Done"
  end

  desc "Add bandwidth counts to existing users"
  task initialize_user_bandwidths: :environment do
    starter_id = BillingPlan.find_by(stripe_plan_id: 'starter').id
    beta_id = BillingPlan.find_by(stripe_plan_id: 'free-for-life').id
    premium_ids = [
      BillingPlan.find_by(stripe_plan_id: 'early-adopters').id,
      BillingPlan.find_by(stripe_plan_id: 'premium').id
    ]

    # Premium
    puts "Setting premium users to 10GB"
    puts User.where(selected_billing_plan_id: premium_ids).update_all(upload_bandwidth_kb: 10_000_000) # 10GB

    # Starter
    puts "Setting starter users to 50MB"
    puts User.where(selected_billing_plan_id: nil).update_all(upload_bandwidth_kb: 50_000) # 50MB
    puts User.where(selected_billing_plan_id: starter_id).update_all(upload_bandwidth_kb: 50_000) # 50MB

    # Beta
    puts "Setting beta users to 250MB"
    puts User.where(selected_billing_plan_id: beta_id).update_all(upload_bandwidth_kb: 250_000) # 250MB
  end
end
