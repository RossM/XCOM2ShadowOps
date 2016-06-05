This mod adds four new classes: Combat Engineer, Dragoon, Hunter, and Infantry. It also changes several game rules and items to support the new classes. The new classes together can fill all the roles of the original classes (except psi) and are designed to completely replace the base classes. I suggest not using other gameplay-changing mods on your first playthrough with this mod, especially if you are using the new classes to replace the basic classes.

By default, this mod adds the new classes in addition to the basic classes. To replace the basic classes entirely, edit XComClassData.ini to set NumInDeck and NumInForcedDeck to 0 for the basic classes.

Beta version v0.7.0
General changes
  * XComModOptions.ini now has options to disable the mod's item and non-class gameplay changes.
Class changes
  Combat Engineer
    * Smoke and Mirrors now provides a bonus smoke grenade use (even if there is no smoke grenade equipped).
    * Breach moved to Pioneer subclass.
	* Fastball moved to Corporal.
	* Dense Smoke moved to Sergeant, Sapper subclass.
	* Aggression moved to Sergeant.
	* Moving Target reduced to +30 defense, +50 dodge (was +40 defense, +100 dodge).
	* Entrench revised: Increase Defense by 30 and Dodge by 50 until you move. Only works in cover.
	* Fracture moved to Captain.
	* Fracture shred increased to 2/4/6 (was 2/3/4).
	* Chain Reaction removed.
	* Combat Drugs moved to Sapper subclass.
	* Combat Drugs bonus increased to +10 aim and +20 crit (was +10 aim and +10 crit).
	* Resilience (from Infantry) added at Major.
    * Packmaster only applies to standard utility slots.
  Dragoon
    * Vanish now has a 2 round cooldown.
  Hunter
    * First Strike applies when either flanking or concealed. (Was only when concealed.)
  Infantry
    * Magnum moved to Rifleman subclass.
	* New Sergeant ability: First Aid. You have one free medikit use on every mission. Each carried medikit gives you two additional uses.
	* Resilience removed (moved to Combat Engineer).
    * Zero In moved to Lieutenant.
	* Flush revised: Fire a pistol shot that automatically hits and forces the target to move to new cover.
	* Ready for Anything removed.
	* New Captain ability: Helping Hand. Using a medikit on an injured unit also grants that unit a bonus action point.
Item changes
  * Depleted Elerium Rounds shred reduced to 2.
Visual changes
  * Flush has a new, improved visualization.
Other changes
  * Scrounger AWC ability removed.
  * New AWC ability: Lightfoot. You have +3 Mobility and are harder to detect while concealed.
  * New AWC ability: Pyromaniac. Your fire attacks deal +1 damage, and your burn effects deal +1 damage per turn. You get a free incendiary grenade on each mission.
  * New AWC ability: Snake Blood. Your poison attacks deal +1 damage, and your poison effects deal +1 damage per turn. You are immune to poison.
  * New AWC ability: Rage. You gain Implacable, Untouchable, and Serial for 3 turns, but you can't choose your own actions.
Bugfixes
  * GTS unlocks now cost 200 on Legendary difficulty.

Beta version v0.6.0
General changes
  * More of the item changes made by the mod can be configured in XComGameCore.ini.
  * Increased compatibility with other mods by removing many class overrides.
  * Many abilities have expanded popup text.
Class changes
  * Infantry
	* Covering Fire is removed.
	* New Lieutenant ability: Fortify. Whenever you enter overwatch or use suppression, you gain +20 Defense until the start of your next turn.
    * Flush now forces the target to move even if the shot misses.
    * Can now equip two ammo items, one in their ammo slot and one in a regular utility slot. They start battle with the ammo in their ammo slot active.
    * New ability: Swap Ammo. Reload your weapons with your other equipped ammo. Costs an action but doesn't end turn as first ability.
  * Combat Engineer
    * Lightning Reflexes is removed.
    * New Lieutenant ability: Moving Target. You get an additional +40 Defense and +100 Dodge against reaction fire.
    * Breach now has a radius of 2 when used with a rifle. It still has its previous radius of 3 when used with a shotgun.
Other changes
  * Returning AWC ability: Hip Fire. Fire your primary weapon at a target. This attack does not cost an action. 3 turn cooldown.
  * New AWC ability: Anatomist. You get a +10 Crit chance bonus for each enemy of the same type you have killed, to a max of +30.
  * New AWC ability: Scrounger. There is a chance of an extra loot drop whenever you are on a mission.
  * New AWC ability: Weaponmaster. Your primary weapon attacks deal +2 damage.
  * New AWC ability: Absolutely Critical. You get an additional +50 Crit chance against flanked or uncovered targets.
  * New AWC ability: Hit and Run. You can take a move action after using a single-action ability as your first action that would normally end your turn.
  * New AWC ability: Devil's Luck. Your Hit chance is increased by 10% and Crit chance is increased by 20%. These bonuses are doubled when you are flanked or out of cover.
Bugfixes
  * Renewal Protocol can no longer bring the dead back to life.
  * Assorted minor fixes.

Beta version v0.5.5
Item changes
  * Hollow-Point Rounds can no longer be sold at the black market.
  * Flechette rounds sell for less at the black market.
Bugfixes
  * Fracture now works.
  * Fixed a conflict with Richard's Engineer mod.
  * Assorted minor fixes.

Beta version v0.5.4
Item changes
  * The Advanced Grenade Launcher has been restored to its previous stats.
Visual/audio changes
  * Zero In and Good Eye have swapped icons.
  * Launching smoke grenades or flashbangs will now play appropriate audio.
Bugfixes
  * Fixed bug where Infantry had trouble using their second utility slot while an ammo item was equipped.
  * Fixed bug that could make Assassin, Focus, and Good Eye sometimes fail to work.
  * Assorted minor fixes.

Beta version v0.5.3
General changes
  * Many abilities have expanded popup text.
Bugfixes
  * Assorted minor fixes for issues caused by 2016-05-12 patch.

Beta version v0.5.2
Bugfixes
  * Assorted minor fixes for issues caused by 2016-05-12 patch.

Beta version v0.5.1
General changes
  * Updated for 2016-05-12 patch.
Visual changes
  * Some skill icons are changed.
Bugfixes
  * Assorted minor fixes.

Beta version v0.5
General changes
  * Mod configuration options are now in XComModOptions.ini (only bDisplaySubclassNames for now).
Ability changes
  Combat Engineer
  * Breach range reduced to 14 (from 18).
  Dragoon
  * Barrage now has only a 50% chance of damaging cover when used with a rifle. It still has a 100% chance when used with a cannon.
  * Renewal Protocol also removes disorientation and panic.
  * Renewal Protocol applies the first tick of regeneration (2 hp) immediately when used.
  Hunter
  * Tracking range increased to 30 (was 27). It now detects units slightly, but only slightly, outside of visual range.
  * Tracking now works even if you don't move.
  Infantry
  * Zero In aim bonus increased to +20 (was +15).
  * Zone of Control will switch to pistol overwatch shots when the primary weapon is out of ammo.
Item changes
  * Flechette Rounds' hit penalty now depends on range. It scales quadratically from 0 at point blank to -10 near maximum visual range.
  * Flechette Rounds now requires Modular Weapons tech and costs 25 resources to build.
Visual changes
  * Mark has an improved visualization.
  * Shield Protocol has an improved visualization.
  * Tracking no longer applies a red outline to units it reveals.
  * Changing equipped weapons will apply the soldier's custom weapon color and pattern if the new weapon doesn't have either.
  * Most class abilities have new or improved icons.
Bugfixes
  * Tracking correctly reveals Faceless inside its range.
  * Assorted minor fixes.

Beta version v0.4
General changes
  * Improved compatibility with other mods.
  * Units no longer panic from taking damage if all of the damage is absorbed by an energy shield.
Ability changes
  * Fracture now doubles the bonus crit damage of the equipped weapon (previously it added 2/4/6 damage based on weapon tech level).
  * Barrage now attacks all targets in a line, but requires 3 ammo points (up from 2).
  * Hip Fire no longer has an aim penalty.
Item changes
  * New item: Tiger Rounds. Unlocked with Hybrid Materials tech. Adds one point of armor shredding to weapon damage.
  * New item: Depleted Elerium Rounds. Unlocked with Elerium tech. Adds one point of damage and three points of shredding to weapon damage.
  * Plated Vest now requires 4 ADVENT Trooper corpses (up from 2).
Visual changes
  * Integrated MachDelta's After Action Days Wounded mod.
Bugfixes
  * Learning Finesse will equip the highest level rifle available.
  * Assorted minor fixes.

Beta version v0.3b
Bugfixes
  * Fixed problem where some items were missing when starting a new game.

Beta version v0.3
General changes
  * The AWC is no longer made retroactive. Install the retroactive AWC mod if you want to preserve the behavior.
  * Improved compatibility with other mods, hopefully.
  * More things can be tuned in the mod ini files.
  * Added comments in XComEngine.ini noting which class overloads can be removed if they are causing conflicts.
Ability changes
  * Suppression now prevents ADVENT MECs from using their missile attack.
  * Hip Fire is now available through the AWC. Hip Fire - Fire your primary weapon at a target. This attack does not cost an action, but has a -20 Aim modifier. 3 turn cooldown.
Item changes
  * Smoke grenades start with 2 charges (up from 1).
  * New experimental armor from the Proving Ground: Reinforced Vest - grants +2 Armor.
Visual changes
  * Integrated Divine Lucubration's Suppression Visualization Fix mod to fix the Rifle Suppression animation.
  * All standard-shot-like abilities now use over-the-shoulder targeting.
Bugfixes
  * Fixed Flush to actually work, for real this time.
  * Combat Engineers can no longer get Lightning Reflexes through the AWC.
Bugs added
  * Probably a lot.

Beta version v0.2
Class changes
  * Dragoon
    * Puppet Protocol succeeds less often.
	* Shield Protocol grants poison immunity while the shield lasts.
	* Renewal Protocol and Stealth Protocol gain a second charge when using a GREMLIN Mk III.
	* New class GTS ability: Tactical Sense - +10 Dodge for each visible enemy, to a max of +50.
  * Engineer
    * Renamed to Combat Engineer.
	* Breach now snaps to tiles.
	* Danger Zone only increases Breach's radius by 1.
	* Packmaster is now the class GTS ability.
	* Entrench is moved from Captain to Lieutenant.
	* New Captain ability: HEAT Ammo - Confers +50% damage against robotic enemies.
  * Hunter
    * Mark now has a 1 turn cooldown (down from 2).
	* Hip Fire is removed.
	* Fade is moved from Corporal to Lieutenant.
	* New Corporal ability: First Strike - While concealed, you deal +3 damage with your sniper rifle and take no penalties from using Squadsight.
	* Sprinter is removed.
	* New Captain ability: Sprint - Gain a bonus move action this turn. (2 turn cooldown)
	* New class GTS ability: Damn Good Ground - +10 Aim and Defense against targets at lower elevation.
  * Infantry
    * Rate of experience gain slightly reduced.
    * Full Auto now costs 2 actions to use.
	* New class GTS ability: Adrenaline Surge - Nearby squadmates get +10 Crit and +3 Mobility when you get a kill. (until end of turn)
Bugfixes
  * Flush works more reliably
  * GREMLINs enter stealth when their owner does
  * Too many others to list
Bugs added
  * Probably too many to list

Beta version v0.1
* Four new classes with eight distinctive subclasses and 48 new abilities.
  * Dragoon - Cannon/Assault Rifle, GREMLIN
    * The Paladin protects his allies with energy shields and regeneration, while dealing devastating damage with the heaviest weapons and armor in XCOM's arsenal.
    * The Ghost moves quickly and quietly, helping her squad to slip past enemies. She's also an expert at hacking enemy robotic units, and can even take permanent control over them.
  * Engineer - Shotgun/Assault Rifle, Grenade Launcher
    * The Pioneer covers himself and his allies with clouds of smoke for protection while he closes with the enemy, then deals massive damage at short range with his shotgun.
    * The Sapper uses grenades and shotgun to demolish cover and shred armor. Her Packmaster ability allows her to carry more grenades than any other class.
  * Hunter - Sniper Rifle, Sword
    * The Marksman delivers long-range tactical support from concealed firing positions. Her ability to weaken enemies from long distance makes her a powerful threat anywhere on the battlefield.
    * The Tracker combines sniper rifle and sword into a unbelievable whirlwind of destruction. Despite his unorthodox choice of weapons, his combination of high mobility and even higher damage is devastatingly effective.
  * Infantry - Assault Rifle, Pistol
    * The Rifleman is good at one thing: dealing damage. Lots of it. With her Bullet Swarm ability, she can fill the battlefield - and the enemies - with as much lead as she can carry.
    * The Support specializes in denying the enemy the ability to move around the battlefield. Whether with deadly accurate suppression fire or all-seeing overwatch, he makes sure that XCOM has the tactical upper hand.
* Several early-game items have been made available from the start of the game.
* Two new ammo types are available from the start of the game.
* Minor tweaks to some game rules and abilities:
  * A low hit chance will also lower crit chance.
  * Suppression prevents throwing or launching grenades, and suppression reaction shots have a +20 bonus.
  * The advanced grenade launcher has been nerfed to not provide additional grenade radius.
  * The disoriented status effect's aim penalty is increased.
  * The AWC has been made retroactive.