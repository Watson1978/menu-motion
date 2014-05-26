module MenuMotion

  class MenuItem < NSMenuItem

    attr_accessor :item_action, :item_target,
                  :root_menu, :tag, :validate

    def initialize(params = {})
      super()
      update(params)
      self
    end

    def perform_action
      if self.valid? && self.valid_target_and_action?
        if self.item_action.to_s.end_with?(":")
          self.item_target.performSelector(self.item_action, withObject: self)
        else
          self.item_target.performSelector(self.item_action)
        end
      end
    end

    def update(params)
      self.item_action = params[:action]    if params.has_key?(:action)
      self.item_target = params[:target]    if params.has_key?(:target)
      self.root_menu   = params[:root_menu] if params.has_key?(:root_menu)
      self.title       = params[:title]     if params.has_key?(:title)
      self.validate    = params[:validate]  if params.has_key?(:validate)

      # Set NSApp as the default target if no other target is given
      if self.item_action && self.item_target.nil?
        self.item_target = NSApp
      end

      # Add sections and/or rows to a submenu
      add_submenu_from_params(params)

      self
    end

    def valid?
      if self.submenu || self.valid_target_and_action?
        if self.validate.nil?
          true
        else
          self.validate.call(self)
        end
      else
        false
      end
    end

    def valid_target_and_action?
      self.item_target && self.item_action && self.item_target.respond_to?(self.item_action.gsub(":", ""))
    end

  private

    def add_submenu_from_params(params)
      if params[:sections]
        submenu = MenuMotion::Menu.new({
          sections: params[:sections]
        }, self.root_menu)
        self.setSubmenu(submenu)
      elsif params[:rows]
        submenu = MenuMotion::Menu.new({
          rows: params[:rows]
        }, self.root_menu)
        self.setSubmenu(submenu)
      end
    end

  end

end

