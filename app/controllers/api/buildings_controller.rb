module Api
  class BuildingsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_client, only: [:create]
    before_action :set_building, only: [:update]
    before_action :validate_custom_fields, only: [:create, :update]

    def index
      buildings = Building.includes(:client, :custom_field_values, :custom_fields)
                          .order(:id)
                          .limit(per_page)
                          .offset(offset)

      render json: success_response(
        buildings: buildings.map { |b| serialize_building(b) },
        pagination: pagination_meta(Building.count)
      )
    end

    def create
      building = @client.buildings.new(building_params)

      ActiveRecord::Base.transaction do
        if building.save
          building.set_custom_field_values!(params[:custom_fields]) if params[:custom_fields].present?
          render json: success_response(
            message: "Building created successfully",
            building: serialize_building(building)
          ), status: :created
        else
          render_errors(building.errors.full_messages, :unprocessable_entity)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      render_errors([e.message], :unprocessable_entity)
    end

    def update
      ActiveRecord::Base.transaction do
        if @building.update(building_params)
          @building.set_custom_field_values!(params[:custom_fields]) if params[:custom_fields].present?
          render json: success_response(
            message: "Building updated successfully",
            building: serialize_building(@building)
          )
        else
          render_errors(@building.errors.full_messages, :unprocessable_entity)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      render_errors([e.message], :unprocessable_entity)
    end

    private

    def set_client
      @client = Client.find_by(id: params[:client_id])
      render_errors(["Client not found"], :not_found) unless @client
    end

    def set_building
      @building = Building.find_by(id: params[:id])
      render_errors(["Building not found"], :not_found) unless @building
    end

    def validate_custom_fields
      return if params[:custom_fields].blank?
      
      client = @client || @building&.client
      return unless client
      
      errors = []
      params[:custom_fields].each do |field_name, value|
        custom_field = client.custom_fields.find_by(name: field_name)
        
        unless custom_field
          errors << "Unknown custom field '#{field_name}' for the client"
          next
        end
        
        next if value.blank?
        
        unless custom_field.valid_value?(value)
          errors << "Invalid value for '#{field_name}': #{custom_field.validation_error(value)}"
        end
      end
      render_errors(errors, :unprocessable_entity) if errors.any?
    end

    def building_params
      params.permit(:street, :city, :state, :zip, :country)
    end

    def serialize_building(building)
      serializer = BuildingSerializer.new(building)
      attributes = serializer.serializable_hash[:data][:attributes]
      custom_fields = attributes.delete(:custom_fields) || {}
      attributes.merge(custom_fields)
    end

    def page
      @page ||= [params[:page].to_i, 1].max
    end

    def per_page
      @per_page ||= params[:per_page].present? ? [params[:per_page].to_i, 100].min : 10
    end

    def offset
      (page - 1) * per_page
    end

    def pagination_meta(total_count)
      {
        current_page: page,
        per_page: per_page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count: total_count
      }
    end

    def success_response(data)
      { status: "success" }.merge(data)
    end

    def render_errors(errors, status)
      render json: { status: "error", errors: errors }, status: status
    end
  end
end
