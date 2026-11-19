# sxHelpMenu_example

Examples of menus made with [sxHelpMenu](https://github.com/0xS4cha/sxHelpMenu): a vehicle widget built with the Lua builder and updated live, and a guide built with the exports only.

## Features

- **Vehicle widget**: shown while the player drives, hidden when they leave the driver seat. Made with the builder of `@sxHelpMenu/lib/menu.lua`.
  - **Statistics**: sliders out of 10 for speed, acceleration, braking and traction, and a footer with a rating and the top speed, like the GTA 6 card.
  - **Live**: speed, RPM, gear and engine health, updated with `SetRow` only while this page is shown and only when a value changed.
  - **Info**: plate, class, seats and doors with tones and icons.
- **Guide**: three pages (welcome, controls, tips) made with `exports.sxHelpMenu:Show`, with a per page header and a footer. It stays open until it is closed with the command or `HideGuide`, or hides itself after an optional duration.
- **Position**: a command moves both menus to one of the nine anchors, saved in the KVP of the player.

## Dependencies

| Resource | Purpose |
| --- | --- |
| [sxHelpMenu](https://github.com/0xS4cha/sxHelpMenu) | Required. Draws the menus |

## Installation

1. Clone the repository into your `resources` folder.

   ```bash
   git clone https://github.com/0xS4cha/sxHelpMenu_example.git
   ```

2. Add the resource to your `server.cfg` after sxHelpMenu.

   ```cfg
   ensure sxHelpMenu
   ensure sxHelpMenu_example
   ```

## Usage

| Key / command | Description |
| --- | --- |
| Drive a vehicle | Shows the vehicle widget |
| `R` | Next page of the last shown menu |
| `/helpexample` | Shows or hides the guide |
| `/helpexample_position <position>` | Moves the menus, `bottom-right` by default |

## Configuration

Everything lives in `shared/config.lua`.

| Key | Default | Description |
| --- | --- | --- |
| `Config.Vehicle.enabled` | `true` | Shows the vehicle widget while driving |
| `Config.Vehicle.position` | `nil` | Anchor of the widget, `nil` uses the default of sxHelpMenu |
| `Config.Vehicle.refresh` | `200` | Milliseconds between two checks of the live values |
| `Config.Guide.command` | `'helpexample'` | Command of the guide |
| `Config.Guide.position` | `nil` | Anchor of the guide |
| `Config.Guide.duration` | `0` | Milliseconds before the guide hides itself, `0` keeps it open until it is closed |
| `Config.PositionCommand` | `'helpexample_position'` | Command that moves the menus |

## How it works

```
client/
  cl_utils.lua     Helpers, speed units and saved position
  cl_vehicle.lua   Vehicle widget made with the builder
  cl_guide.lua     Guide made with the exports and the position command
shared/            Configuration
```

The vehicle widget is built once when the player takes the driver seat, with the model statistics read from the game. While the live page is shown, the values are read every `Config.Vehicle.refresh` ms and sent with `SetRow` only when they changed, with `scramble = false` on the gear so the text does not animate on every update. The `sxHelpMenu:pageChanged` event refreshes the values as soon as the player opens the live page.

When the menus are moved, the widget calls `Position` then `Refresh` on the builder and the guide calls `Update`, so both keep their page.

## Exports

### Client

| Export | Description |
| --- | --- |
| `ShowGuide(duration?)` | Shows the guide, `duration` in milliseconds replaces `Config.Guide.duration`, `0` keeps it open |
| `HideGuide()` | Hides the guide |
| `IsGuideVisible()` | Returns whether the guide is shown |

```lua
exports.sxHelpMenu_example:ShowGuide()
exports.sxHelpMenu_example:HideGuide()
```

## License

Released under the [MIT License](LICENSE).
