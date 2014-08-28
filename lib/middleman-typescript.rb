require "middleman-core"

::Middleman::Extensions.register(:typescript) do
  require "middleman-typescript/extension"
  ::Middleman::TypescriptExtension
end