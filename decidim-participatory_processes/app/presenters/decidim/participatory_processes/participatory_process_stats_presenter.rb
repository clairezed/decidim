# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render statistics in the homepage.
    class ParticipatoryProcessStatsPresenter < Rectify::Presenter
      attribute :participatory_process, Decidim::ParticipatoryProcess
      include Decidim::IconHelper

      # Public: Render a collection of primary stats.
      def highlighted
        highlighted_stats = feature_stats(priority: StatsRegistry::HIGH_PRIORITY)
        highlighted_stats = highlighted_stats.concat(feature_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
        highlighted_stats = highlighted_stats.reject(&:empty?)
        highlighted_stats = highlighted_stats.reject { |_manifest, _name, data| data.zero? }
        grouped_highlighted_stats = highlighted_stats.group_by { |stats| stats.first.name }

        safe_join(
          grouped_highlighted_stats.map do |_manifest_name, stats|
            content_tag :div, class: "process_stats-item" do
              safe_join(
                stats.each_with_index.map do |stat, index|
                  render_stats_data(stat[0], stat[1], stat[2], index)
                end
              )
            end
          end
        )
      end

      private

      def feature_stats(conditions)
        Decidim.feature_manifests.map do |feature_manifest|
          feature_manifest.stats.filter(conditions).with_context(published_features).map { |name, data| [feature_manifest, name, data] }.flatten
        end
      end

      def render_stats_data(feature_manifest, name, data, index)
        safe_join([
                    index.zero? ? feature_manifest_icon(feature_manifest) : " /&nbsp".html_safe,
                    content_tag(:span, "#{number_with_delimiter(data)} " + I18n.t(name, scope: "decidim.participatory_processes.statistics"),
                                class: "#{name} process_stats-text")
                  ])
      end

      def published_features
        @published_features ||= Feature.where(participatory_space: participatory_process).published
      end
    end
  end
end
