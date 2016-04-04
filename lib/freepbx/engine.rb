module Freepbx
  class Engine < ::Rails::Engine
    isolate_namespace Freepbx
    config.generators.api_only = true
  end
end
