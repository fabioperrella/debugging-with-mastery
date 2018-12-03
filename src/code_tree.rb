require 'tty-tree'

tree = TTY::Tree.new do
  node 'UserRecommendations.list' do
    node 'UserRecommendations#list' do
      node 'fetchers'
      node 'sort_by' do
        node 'ItemsFetcher::Main.order' do
        end
        node 'ItemsFetcher::Secondary.order' do
        end
        node 'ItemsFetcher::Sponsored.order' do
        end
      end
      node 'map' do
        node 'ItemsFetcher::Main.fetch' do
          node 'ItemsFetcher::Main#fetch' do
            node 'ItemsFetcher::Main#main_preferences'
          end
        end
        node 'ItemsFetcher::Secondary.fetch' do
          node 'ItemsFetcher::Secondary#fetch' do
            node 'ItemsFetcher::Secondary#secondary_preferences'
          end
        end
        node 'ItemsFetcher::Sponsored.fetch' do
          node 'ItemsFetcher::Sponsored#fetch' do
            node 'ItemsFetcher::Sponsored#fetch' do
              node 'each' do
                node 'SponsoredMetrics.new' do
                  node 'SponsoredMetrics#save' do
                    node 'SponsoredMetrics#key'
                    node 'SponsoredMetrics#value'
                    node 'Metrics.save' do
                      node 'Rails.cache.save'
                    end
                  end
                end
              end
            end
          end
        end
      end
      node 'inject'
      node 'reject' do
        node 'UserRecommendations#watched_items'
      end
    end
  end
end

puts tree.render