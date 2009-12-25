module YARD
  module Templates
    module Helpers
      module HtmlSyntaxHighlightHelper
        include ModuleHelper
        
        def html_syntax_highlight_ruby(source)
          tokenlist = Parser::Ruby::RubyParser.parse(source, "(syntax_highlight)").tokens
          output = ""
          tokenlist.each_with_index do |s, i|
            output << "<span class='tstring'>" if [:tstring_beg, :regexp_beg].include?(s[0])
            case s.first
            when :nl, :ignored_nl, :sp
              output << h(s.last)
            when :ident, :const
              klass = s.first == :ident ? "id #{h(s.last)}" : s.first
              token = html_syntax_link_const(tokenlist, i)
              output << "<span class='#{klass}'>#{token}</span>"
            else
              output << "<span class='#{s.first}'>#{h(s.last)}</span>"
            end
            output << "</span>" if [:tstring_end, :regexp_end].include?(s[0])
          end
          output
        rescue Parser::ParserSyntaxError
          h(source)
        end
        
        private
        
        def html_syntax_link_const(tokenlist, index)
          token = tokenlist[index]
          if token.first == :const
            text = h(group_const_path_ref(token.last, tokenlist, index + 1))
          else
            text = h(token.last)
          end
          if obj = Registry.resolve(object.namespace || :root, token.last)
            if obj.is_a?(CodeObjects::MethodObject)
              obj = prune_method_listing([obj], false).first
            else
              obj = run_verifier([obj]).first
            end
            if obj && obj != object
              text = link_object(obj, text)
            end
          end
          text
        end
        
        def group_const_path_ref(token, tokenlist, start_index)
          return token unless tokenlist[start_index] == [:op, '::']
          token = token.dup
          nxt = tokenlist[start_index]
          while nxt && (nxt == [:op, '::'] || nxt.first == :const)
            token << nxt.last
            tokenlist.delete_at(start_index + 1)
            nxt = tokenlist[start_index + 1]
          end
          token
        end
      end
    end
  end
end