require 'yaml'
require 'andand'

module ELA
  module Utils
    def write_settings_yml(path)
      File.write(path, settings)
    end

    def write_labels_yml(path)
      File.write(path, labels)
    end

    def write_yml(name, path)
      case name
      when :settings then write_settings_yml(path)
      when :labels then write_labels_yml(path)
      end
    end

    def settings
      preamble = <<EOF
  # PLEASE DO NOT CHANGE THIS FILE, YOUR CHANGES WILL BE LOST AFTER THE NEXT UPDATE
  # Create a file `settings.overwrite.yml.txt` and place particular changes there. Example:
  #
  # directOperatingCosts:
  #   airplanes:
  #     A 300 B4-200:
  #       speed: 855
  #     ILR Super Aircraft:
  #       maxTakeOffMass: 165000
  #       maxFuelMass: 59646
  #       operationEmptyMass: 80640
  #       maxPayload: 45360
  #       maxRange: 8412
  #       speed: 2300
  #       engineCount: 6
  #       slst: 233
  #       engine: 6 x 233kN CF6-50C2
  #       reference: ILR12345
  # beamSectionProperties:
  #   zProfile:
  #     defaults:
  #       h: 12.5
  #
  # Structure:
  #
  # {appName}:
  #   curves:
  #     {curveName}:
  #       group: {groupName} # Translation in labels.yml.txt file at {appName} -> listAnchors -> {groupName} -> label
  #       selected: (true|false)
  #   defaults:
  #     {parameterName}: {parameterDefaultValue}
  #   formFields:
  #     {fieldName}:
  #       range: [{fieldFrom}, {fieldTo}] # including boundary values
  #       stepSize: {fieldStepSize}
  #       group: {fieldGroupName} # Translated to "Field Group Name"
  #       precision: {fieldPrecision} # Decimal places for computed fields
  #   {subappPath}: # subapp settings are more specific and therfore supercede settings from parent layers
  #     curves:
  #       {curveName}:
  #         selected: (true|false)
  #
  # In this file, all curves, parameters and formFields are present even if they have no dedicated settings.

EOF
      preamble + yml_config(:settings)
    end

    def labels
      preamble = <<EOF
  # PLEASE DO NOT CHANGE THIS FILE, YOUR CHANGES WILL BE LOST AFTER THE NEXT APP UPDATE
  # Create a file `labels.overwrite.yml.txt` and place particular changes there. Example:
  #
  # airplaneInternalLoads:
  #   fuselage:
  #     shortTitle: FLL
  # mohrsCircle:
  #   shortTitle: Mohr's Circus

EOF
      preamble + yml_config(:labels)
    end

    def yml_config(name)
      global_yml_path = File.join(Dir.pwd, "#{name}.yml")
      s = ''
      if File.exists?(global_yml_path)
        s += File.read(global_yml_path)
      end

      apps = ''
      app_settings = ''
      apps_path = File.join(Dir.pwd, 'apps')

      Dir.new(apps_path).each do |entry|
        next if ['.', '..'].include?(entry)

        entry_path = File.join(apps_path, entry)
        next unless File.directory?(entry_path)

        apps += "  - #{entry}\n"
        app_settings += "#{entry}:\n"

        app_yml_path = File.join(entry_path, "#{name}.yml")
        if File.exists?(app_yml_path)
          File.readlines(app_yml_path).each do |line|
            app_settings += "  #{line}"
          end
        end
      end

      if name == :settings
        s += "apps:\n#{apps}"
      end

      s + app_settings
    end

    def page_title
      global_settings_path = File.join(Dir.pwd, 'settings.yml')
      if File.exists?(global_settings_path)
        yml = YAML.load(File.read(global_settings_path))
        yml_title = yml['page'].andand['title']
      end
      yml_title or 'E-Learning Apps'
    end
  end
end
