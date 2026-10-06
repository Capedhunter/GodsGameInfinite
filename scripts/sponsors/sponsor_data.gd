class_name SponsorData
extends Resource

## A Sponsor is a manifestation of humanity's perception of a myth, legend,
## theological figure, or other enduring cultural idea.
##
## Sponsors have their own personalities, but they always follow their chosen
## character's commands. Their personality is expressed through dialogue,
## advice, reactions, and relationship development.

@export_category("Identity")
@export var sponsor_name: String = "Sponsor"
@export var mythological_source: String = ""
@export_multiline var manifestation_description: String = ""
@export var ideological_themes: Array[String] = []

@export_category("Personality")
@export_multiline var personality_description: String = ""
@export var personality_traits: Array[String] = []
@export_multiline var relationship_note: String = ""

@export_category("Compatibility")
@export var compatibility_groups: Array[String] = []

@export_category("Combat")
@export var affinity_profile: AffinityProfile
@export var skills: Array[BattleSkill] = []
@export var passive_traits: Array[String] = []
@export var max_active_skills: int = 8

@export_category("Progression")
@export var level: int = 1
@export var experience: int = 0
@export var passive_slots: int = 1
@export_multiline var evolution_description: String = ""

func is_compatible_with_group(group: String) -> bool:
    return group in compatibility_groups
