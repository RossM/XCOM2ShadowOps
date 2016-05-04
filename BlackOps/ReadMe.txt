This mod adds four new classes: Combat Engineer, Dragoon, Hunter, and Infantry. It also changes several game rules and items to support the new classes. The new classes together can fill all the roles of the original classes (except psi) and are designed to completely replace the base classes. I suggest not using other gameplay-changing mods on your first playthrough with this mod, especially if you are using the new classes to replace the basic classes.

By default, this mod adds the new classes in addition to the basic classes. To replace the basic classes entirely, edit XComClassData.ini to set NumInDeck and NumInForcedDeck to 0 for the basic classes.

Beta version v0.5
General changes
  * Mod configuration options are now in XComModOptions.ini (only bDisplaySubclassNames for now).
Ability changes
  * Breach range reduced to 14 (from 18).
Item changes
  * Flechette Rounds' hit penalty now depends on range. It scales quadratically from 0 at point blank to -10 near maximum visual range.
  * Flechette Rounds now requires Modular Weapons tech and costs 25 resources to build.
Visual changes
  * Mark has an improved visualization.
  * Shield Protocol has an improved visualization.
  * Tracking no longer applies a red outline to units it reveals.
  * Changing equipped weapons will apply the soldier's custom weapon color and pattern.
Bugfixes
  * Tracking correctly reveals Faceless inside its range.

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