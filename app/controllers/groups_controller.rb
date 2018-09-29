class GroupsController < ContentController
  private

  def content_param_list
    %i(
      name description other_names universe_id
      organization_structure privacy
      motivation goal obstacles risks
      inventory notes private_notes
    ) + [
      custom_attribute_values:         [:name, :value],
      group_leaderships_attributes:    [:id, :leader_id, :_destroy],
      group_memberships_attributes:    [:id, :member_id, :_destroy],
      supergroupships_attributes:      [:id, :supergroup_id, :_destroy],
      subgroupships_attributes:        [:id, :subgroup_id, :_destroy],
      sistergroupships_attributes:     [:id, :sistergroup_id, :_destroy],
      group_allyships_attributes:      [:id, :ally_id, :_destroy],
      group_enemyships_attributes:     [:id, :enemy_id, :_destroy],
      group_rivalships_attributes:     [:id, :rival_id, :_destroy],
      group_clientships_attributes:    [:id, :client_id, :_destroy],
      group_supplierships_attributes:  [:id, :supplier_id, :_destroy],
      group_locationships_attributes:  [:id, :location_id, :_destroy],
      headquarterships_attributes:     [:id, :headquarter_id, :_destroy],
      officeships_attributes:          [:id, :office_id, :_destroy],
      group_equipmentships_attributes: [:id, :equipment_id, :_destroy],
      key_itemships_attributes:        [:id, :key_item_id, :_destroy],
      group_creatures_attributes:      [:id, :creature_id, :_destroy]
    ]
  end
end
