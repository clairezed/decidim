# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessStepForm do
        let(:title) do
          {
            en: "Title",
            es: "Título",
            ca: "Títol"
          }
        end
        let(:description) do
          {
            en: "Description",
            es: "Descripción",
            ca: "Descripció"
          }
        end
        let(:start_date) {}
        let(:end_date) {}
        let(:attributes) do
          {
            "participatory_process_step" => {
              "title_en" => title[:en],
              "title_es" => title[:es],
              "title_ca" => title[:ca],
              "description_en" => description[:en],
              "description_es" => description[:es],
              "description_ca" => description[:ca],
              "start_date" => start_date,
              "end_date" => end_date
            }
          }
        end
        let(:organization) { build(:organization) }

        subject { described_class.from_params(attributes).with_context(current_organization: organization) }

        describe "dates" do
          context "when the dates are set" do
            let(:start_date) { Time.new(2016, 1, 1, 15, 0) }
            let(:end_date) { Time.new(2016, 1, 1, 15, 0) }

            it "returns them at midnight" do
              expect(subject.start_date).to eq(Time.new(2016, 1, 1, 0, 0))
              expect(subject.end_date).to eq(Time.new(2016, 1, 1, 0, 0))
            end
          end

          context "when no dates" do
            it "returns nil" do
              expect(subject.start_date).to eq(nil)
              expect(subject.end_date).to eq(nil)
            end
          end
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when some language in title is missing" do
          let(:title) do
            {
              en: "Title",
              ca: "Títol"
            }
          end

          it { is_expected.to be_invalid }
        end

        context "when the start_date is later than end_date" do
          let(:start_date) { 1.month.from_now }
          let(:end_date) { 2.months.ago }

          it { is_expected.to be_invalid }

          it "has an error" do
            subject.valid?

            expect(subject.errors).not_to be_empty
            expect(subject.errors[:end_date]).not_to be_empty
            expect(subject.errors[:start_date]).not_to be_empty
          end
        end

        context "when start_date is present" do
          let(:start_date) { 1.month.from_now }

          it { is_expected.to be_valid }
        end

        context "when end_date is present" do
          let(:end_date) { 2.months.ago }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
