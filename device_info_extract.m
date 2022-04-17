%% returns the index list from the device_info_lst where the device_info is located
function device_info_idx = device_info_extract(device_info, device_info_lst)
  device_info_idx = [];
  % for each row in the device pair list
  for i = 1:size(device_info_lst, 1)
    if isequal(device_info, device_info_lst(i, :))
      device_info_idx = [device_info_idx i];
    end
  end
end