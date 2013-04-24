module Jekyll
  module AssetFilter
    def cdn(input)
       if ENV['OCTOPRESS_ENV'] == "preview"
         # if we are in preview mode, use local for everything
         "/#{input}"
       else
          # if root isn't set to something weird, use cdn var
          if @context.registers[:site].config['root'] == "/"
            "#{@context.registers[:site].config['cdn']}/#{input}"
          # if root is set, go ahead and use it, instead of cdn
          else
            "#{@context.registers[:site].config['root']}/#{input}"
          end
       end
    end
  end
end

Liquid::Template.register_filter(Jekyll::AssetFilter)
