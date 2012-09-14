def ensure_data_bag(bag)
    begin
      data_bag(bag)
  rescue
      new_bag = Chef::DataBag.new
      new_bag.name(bag)
      new_bag.save
  end
end