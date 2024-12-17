<!-- markdownlint-disable-file MD010 -->
# Pet Files

## Important Notes

- The folder your pet file is in must be unique or issues may arise.
- If any values are missing / left blank, it will be replaced with values from `src/pets/internal/dummy.json`
- If your JSON file is invalid, your pet(s) may not be imported.
- If you want to make sprites for your pets, see `PetSprites.md`. Make sure the folder where the sprites are located is the same name as the pet file.

## Quick Reference

You can find all this data in `src/pets/internal/dummy.json`
Speaking of which, do not delete that file, under any circumstances.

```json
{
	"namespace": "internal/dummy",
	"name": "Dummy",
	"can_be_given_by_professor": false,
	"gender": {
		"can_be_female": true,
		"female_chance": 50,
		"can_be_male": true,
		"male_chance": 50
	},
	"biology": {
		"average_weight": 1,
		"average_height": 1,
		"height_mutation": 0.5,
		"weight_mutation": 0.5,
		"weight_can_be_influenced": false,
		"height_can_be_influenced": false,
		"collision_shape_radius": 0,
		"collision_shape_offset": {
			"x": 0,
			"y": 0
		}
	},
	"preferences": {
		"flavor_preference": 0,
		"upset_happiness": 15,
		"neutral_happiness": 50,
		"delighted_happiness": 70,
		"loved_happiness": 90,
		"hunger_rate": 1,
		"saturation_rate": 1,
		"bedtime": {
			"hour": 20,
			"minute": 30,
			"second": 0
		},
		"waketime": {
			"hour": 8,
			"minute": 30,
			"second": 0
		}
	},
	"evolutions": {
		"internal/dummy": {
			"can_evolve_at_day": true,
			"can_evolve_at_night": true,
			"can_evolve_in_winter": true,
			"can_evolve_in_spring": true,
			"can_evolve_in_summer": true,
			"can_evolve_in_fall": true,
			"requires_hold_item": null,
			"required_ev_friendship": 50
		}
	}
}
```

## Generic Variables

### Namespace

Refers to the path that you would find the pet at. The standard form for this is `mod_name/pet_name`. This may be used in the future, but does nothing right now.

### Name

The display name of the pet. This is the name the player sees. Can be left as an empty string, although not recommended.

### Can Be Given By Professor

Boolean that determines if the Professor can give you this egg randomly. This is the only way to obtain eggs as of right now.

## Gender Variables

### Can Be Female / Male

Boolean that determines if the pet can be female / male. If both are off, then the pet will be genderless.

### Male / Female Chance

Number from 1 - 100 (clamped up or down if needed) that determines the chance of gender.
Only the lowest value will be checked against RNG.
Does not apply if the pet is genderless.

## Biology Variables

### Average Weight / Height

Determines the average weight (KG) / height (CM) for the pet.

### Weight / Height Mutation

The range of "mutation". Basically, the weight / height range of which a newly born pet can have. If set to zero, the weight / height of the pet will always be the average.

### Weight / Height Can Be Influenced

Boolean that determines if the weight / height of a pet can be influenced by gameplay actions. I.E: Eating food increases weight, or sleeping for long periods of time increases height.

### Scale

Scale of the sprite. This also affects the collision shape size. This should NEVER be less than or equal to 0.

### Collision Shape Radius

Determines how big the hitbox for the pet should be. You would typically set this to half of the pet's sprite height. If you're unsure, refer to PetSprites.md.

### Collision Shape Offset X/Y

Offsets the hitbox. By default, the hitbox is in the center of the sprite. If you're unsure, refer to PetSprites.md.

## Preference Variables

### Flavor Preference

Integer from 0 to 5. Where 0 is very salty and 5 is very sweet.

### Upset / Neutral / Delighted / Loved Happiness

Integer from 0 to 100. This determines the pets mood. Mood is determined by `mood_value <= current_happiness`. It is recommended that you set the values to the following:

- Upset: 0
- Neutral: 25
- Delighted / Happy: 55
- Loved: 85

If the happiness goes below Upset (because it wasn't set to 0), the pet will be "devastated" and will run away once the game is closed / minimized unless the player recovers their happiness.

### Hunger Rate

Speed at which the pet gets more hungry, with 1 being the standard. 2 and above will make hunger drain faster while anything below one will make it drain slower.

### Saturation Rate

Rate at which food cures hunger. Recommended that you set this value to be lower or equal to Hunger Rate for optimal gameplay.

### Bedtime / Waketime

Times at which the pet may wake up / fall asleep (in 24-hour time). This will always trigger at the indicated time for the player's local time, so no need to worry about timezones.

## Evolutions

Evolutions MUST have the key set to the namespace of the pet you want it to evolve into. For example, if you have a pet in a folder called Cats, and you wanted a kitty to evolve into a Ginger Cat, you would put:

```jsonc
    "evolutions": {
        "cats/ginger_cat": {
            // ...
        }
    }
```

### Evolution Tags

Tags determine how a pet can evolve under specific conditions. The tags are very self explanatory, so I don't think I'd need to explain much here.

#### EV Friendship

This is a hidden stat that determines when a pet should evolve. It starts at 5, and goes up if the pet is very happy, and goes down if the pet is upset / devastated.

If this ever reaches 0, and the pet's happiness reaches upset / devastated, the pet will run away without waiting for the game to close.

To prevent abuse, you cannot set this initially.
