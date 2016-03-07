# Settings for Aliyun OSS and other infrastructurs
class DataProxySettings < Confu
  for_environment(:default) do
    default_cache_for 30
  end

  for_environment(:production) do
  end
end
