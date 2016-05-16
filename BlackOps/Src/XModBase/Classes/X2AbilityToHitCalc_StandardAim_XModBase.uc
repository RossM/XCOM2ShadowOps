class X2AbilityToHitCalc_StandardAim_XModBase extends X2AbilityToHitCalc_StandardAim config(GameCore);

// This class overrides X2AbilityToHitCalc_StandardAim to have it call the methods in
// X2Effect_XModBase.

// Copied from X2AbilityToHitCalc and modified.
protected function int GetHitChance(XComGameState_Ability kAbility, AvailableTarget kTarget, optional bool bDebugLog=false)
{
	local XComGameState_Unit UnitState, TargetState;
	local XComGameState_Item SourceWeapon;
	local GameRulesCache_VisibilityInfo VisInfo;
	local array<X2WeaponUpgradeTemplate> WeaponUpgrades;
	local int i, iWeaponMod, iRangeModifier, Tiles;
	local ShotBreakdown EmptyShotBreakdown;
	local array<ShotModifierInfo> EffectModifiers, FinalEffectModifiers;
	local StateObjectReference EffectRef;
	local XComGameState_Effect EffectState;
	local XComGameStateHistory History;
	local bool bFlanking, bIgnoreGraze, bSquadsight, bIgnoreCrit;
	local string IgnoreGrazeReason, IgnoreCritReason;
	local X2AbilityTemplate AbilityTemplate;
	local array<XComGameState_Effect> StatMods;
	local array<float> StatModValues;
	local X2Effect_Persistent PersistentEffect;
	local X2Effect_XModBase XModBaseEffect;
	local array<X2Effect_Persistent> UniqueToHitEffects;
	local float FinalAdjust, CoverValue, AngleToCoverModifier, Alpha;
	local bool bShouldAddAngleToCoverBonus;
	local TTile UnitTileLocation, TargetTileLocation;
	local ECoverType NextTileOverCoverType;
	local int TileDistance;
	local ShotModifierInfo Mod;

	`log("=" $ GetFuncName() $ "=", bDebugLog, 'XCom_HitRolls');
	m_bDebugModifiers = bDebugLog;

	//  @TODO gameplay handle non-unit targets
	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID( kAbility.OwnerStateObject.ObjectID ));
	TargetState = XComGameState_Unit(History.GetGameStateForObjectID( kTarget.PrimaryTarget.ObjectID ));
	if (kAbility != none)
	{
		AbilityTemplate = kAbility.GetMyTemplate();
		SourceWeapon = kAbility.GetSourceWeapon();			
	}

	//  reset shot breakdown
	m_ShotBreakdown = EmptyShotBreakdown;
	//  add all of the built-in modifiers
	if (bGuaranteedHit)
	{
		Mod.Value = 100;
		Mod.Reason = AbilityTemplate.LocFriendlyName;
		Mod.ModType = eHit_Success;
		m_ShotBreakdown.Modifiers.AddItem(Mod);
		m_ShotBreakdown.ResultTable[Mod.ModType] += Mod.Value;
		m_ShotBreakdown.FinalHitChance = m_ShotBreakdown.ResultTable[eHit_Success];
	}
	AddModifier(BuiltInHitMod, AbilityTemplate.LocFriendlyName, eHit_Success);
	AddModifier(BuiltInCritMod, AbilityTemplate.LocFriendlyName, eHit_Crit);

	if (bIndirectFire)
	{
		m_ShotBreakdown.HideShotBreakdown = true;
		AddModifier(100, AbilityTemplate.LocFriendlyName, eHit_Success);
	}

	if (UnitState != none && TargetState == none)
	{
		// when targeting non-units, we have a 100% chance to hit. They can't dodge or otherwise
		// mess up our shots
		m_ShotBreakdown.HideShotBreakdown = true;
		AddModifier(100, class'XLocalizedData'.default.OffenseStat);
	}
	else if (UnitState != none && TargetState != none)
	{				
		if (!bIndirectFire)
		{
			// StandardAim (with direct fire) will require visibility info between source and target (to check cover). 
			if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(UnitState.ObjectID, TargetState.ObjectID, VisInfo))
			{	
				if (UnitState.CanFlank() && TargetState.GetMyTemplate().bCanTakeCover && VisInfo.TargetCover == CT_None)
					bFlanking = true;
				if (VisInfo.bClearLOS && !VisInfo.bVisibleGameplay)
					bSquadsight = true;

				// XModBase: Check for abilities that negate squadsight penalty
				if (bSquadsight)
				{
					foreach UnitState.AffectedByEffects(EffectRef)
					{
						EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
						PersistentEffect = EffectState.GetX2Effect();
						XModBaseEffect = X2Effect_XModBase(PersistentEffect);
						if (XModBaseEffect != none)
						{
							if (XModBaseEffect.IgnoreSquadsightPenalty(kAbility, UnitState, TargetState))
							{
								bSquadsight = false;
								break;
							}
						}
					}
				}

				//  Add basic offense and defense values
				AddModifier(UnitState.GetBaseStat(eStat_Offense), class'XLocalizedData'.default.OffenseStat);			
				UnitState.GetStatModifiers(eStat_Offense, StatMods, StatModValues);
				for (i = 0; i < StatMods.Length; ++i)
				{
					AddModifier(int(StatModValues[i]), StatMods[i].GetX2Effect().FriendlyName);
				}
				//  Flanking bonus (do not apply to overwatch shots)
				if (bFlanking && !bReactionFire && !bMeleeAttack)
				{
					AddModifier(UnitState.GetCurrentStat(eStat_FlankingAimBonus), class'XLocalizedData'.default.FlankingAimBonus);
				}
				//  Squadsight penalty
				if (bSquadsight)
				{
					Tiles = UnitState.TileDistanceBetween(TargetState);
					//  remove number of tiles within visible range (which is in meters, so convert to units, and divide that by tile size)
					Tiles -= UnitState.GetVisibilityRadius() * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER / class'XComWorldData'.const.WORLD_StepSize;
					if (Tiles > 0)      //  pretty much should be since a squadsight target is by definition beyond sight range. but... 
						AddModifier(default.SQUADSIGHT_DISTANCE_MOD * Tiles, class'XLocalizedData'.default.SquadsightMod);
				}

				//  Check for modifier from weapon 				
				if (SourceWeapon != none)
				{
					iWeaponMod = SourceWeapon.GetItemAimModifier();
					AddModifier(iWeaponMod, class'XLocalizedData'.default.WeaponAimBonus);

					WeaponUpgrades = SourceWeapon.GetMyWeaponUpgradeTemplates();
					for (i = 0; i < WeaponUpgrades.Length; ++i)
					{
						if (WeaponUpgrades[i].AddHitChanceModifierFn != None)
						{
							if (WeaponUpgrades[i].AddHitChanceModifierFn(WeaponUpgrades[i], VisInfo, iWeaponMod))
							{
								AddModifier(iWeaponMod, WeaponUpgrades[i].GetItemFriendlyName());
							}
						}
					}
				}
				//  Target defense
				//  XModBase: Defensive modifiers are broken out separately in the shot breakdown.
				//            Vanilla rolls them all into one "Defense" modifier.
				AddModifier(-TargetState.GetBaseStat(eStat_Defense), class'XLocalizedData'.default.DefenseStat);			
				TargetState.GetStatModifiers(eStat_Defense, StatMods, StatModValues);
				for (i = 0; i < StatMods.Length; ++i)
				{
					AddModifier(-int(StatModValues[i]), StatMods[i].GetX2Effect().FriendlyName);
				}
				
				//  Add weapon range
				if (SourceWeapon != none)
				{
					iRangeModifier = GetWeaponRangeModifier(UnitState, TargetState, SourceWeapon);
					AddModifier(iRangeModifier, class'XLocalizedData'.default.WeaponRange);
				}			
				//  Cover modifiers
				if (bMeleeAttack)
				{
					AddModifier(MELEE_HIT_BONUS, class'XLocalizedData'.default.MeleeBonus, eHit_Success);
				}
				else
				{
					//  Add cover penalties
					if (TargetState.CanTakeCover())
					{
						// if any cover is being taken, factor in the angle to attack
						if( VisInfo.TargetCover != CT_None )
						{
							switch( VisInfo.TargetCover )
							{
							case CT_MidLevel:           //  half cover
								AddModifier(-LOW_COVER_BONUS, class'XLocalizedData'.default.TargetLowCover);
								CoverValue = LOW_COVER_BONUS;
								break;
							case CT_Standing:           //  full cover
								AddModifier(-HIGH_COVER_BONUS, class'XLocalizedData'.default.TargetHighCover);
								CoverValue = HIGH_COVER_BONUS;
								break;
							}

							TileDistance = UnitState.TileDistanceBetween(TargetState);

							// from Angle 0 -> MIN_ANGLE_TO_COVER, receive full MAX_ANGLE_BONUS_MOD
							// As Angle increases from MIN_ANGLE_TO_COVER -> MAX_ANGLE_TO_COVER, reduce bonus received by lerping MAX_ANGLE_BONUS_MOD -> MIN_ANGLE_BONUS_MOD
							// Above MAX_ANGLE_TO_COVER, receive no bonus

							//`assert(VisInfo.TargetCoverAngle >= 0); // if the target has cover, the target cover angle should always be greater than 0
							if( VisInfo.TargetCoverAngle < MAX_ANGLE_TO_COVER && TileDistance <= MAX_TILE_DISTANCE_TO_COVER )
							{
								bShouldAddAngleToCoverBonus = (UnitState.GetTeam() == eTeam_XCom);

								// We have to avoid the weird visual situation of a unit standing behind low cover 
								// and that low cover extends at least 1 tile in the direction of the attacker.
								if( (SHOULD_DISABLE_BONUS_ON_ANGLE_TO_EXTENDED_LOW_COVER && VisInfo.TargetCover == CT_MidLevel) ||
									(SHOULD_ENABLE_PENALTY_ON_ANGLE_TO_EXTENDED_HIGH_COVER && VisInfo.TargetCover == CT_Standing) )
								{
									UnitState.GetKeystoneVisibilityLocation(UnitTileLocation);
									TargetState.GetKeystoneVisibilityLocation(TargetTileLocation);
									NextTileOverCoverType = NextTileOverCoverInSameDirection(UnitTileLocation, TargetTileLocation);

									if( SHOULD_DISABLE_BONUS_ON_ANGLE_TO_EXTENDED_LOW_COVER && VisInfo.TargetCover == CT_MidLevel && NextTileOverCoverType == CT_MidLevel )
									{
										bShouldAddAngleToCoverBonus = false;
									}
									else if( SHOULD_ENABLE_PENALTY_ON_ANGLE_TO_EXTENDED_HIGH_COVER && VisInfo.TargetCover == CT_Standing && NextTileOverCoverType == CT_Standing )
									{
										bShouldAddAngleToCoverBonus = false;

										Alpha = FClamp((VisInfo.TargetCoverAngle - MIN_ANGLE_TO_COVER) / (MAX_ANGLE_TO_COVER - MIN_ANGLE_TO_COVER), 0.0, 1.0);
										AngleToCoverModifier = Lerp(MAX_ANGLE_PENALTY,
											MIN_ANGLE_PENALTY,
											Alpha);
										AddModifier(Round(-1.0 * AngleToCoverModifier), class'XLocalizedData'.default.BadAngleToTargetCover);
									}
								}

								if( bShouldAddAngleToCoverBonus )
								{
									Alpha = FClamp((VisInfo.TargetCoverAngle - MIN_ANGLE_TO_COVER) / (MAX_ANGLE_TO_COVER - MIN_ANGLE_TO_COVER), 0.0, 1.0);
									AngleToCoverModifier = Lerp(MAX_ANGLE_BONUS_MOD,
																MIN_ANGLE_BONUS_MOD,
																Alpha);
									AddModifier(Round(CoverValue * AngleToCoverModifier), class'XLocalizedData'.default.AngleToTargetCover);
								}
							}
						}
					}
					//  Add height advantage
					if (UnitState.HasHeightAdvantageOver(TargetState, true))
					{
						AddModifier(class'X2TacticalGameRuleset'.default.UnitHeightAdvantageBonus, class'XLocalizedData'.default.HeightAdvantage);
					}

					//  Check for height disadvantage
					if (TargetState.HasHeightAdvantageOver(UnitState, false))
					{
						AddModifier(class'X2TacticalGameRuleset'.default.UnitHeightDisadvantagePenalty, class'XLocalizedData'.default.HeightDisadvantage);
					}
				}
			}

			if (UnitState.IsConcealed())
			{
				`log("Shooter is concealed, target cannot dodge.", bDebugLog, 'XCom_HitRolls');
			}
			else
			{
				if (SourceWeapon == none || SourceWeapon.CanWeaponBeDodged())
					AddModifier(TargetState.GetCurrentStat(eStat_Dodge), class'XLocalizedData'.default.DodgeStat, eHit_Graze);
			}
		}					

		//  Now check for critical chances.
		if (bAllowCrit)
		{
			AddModifier(UnitState.GetBaseStat(eStat_CritChance), class'XLocalizedData'.default.CharCritChance, eHit_Crit);
			UnitState.GetStatModifiers(eStat_CritChance, StatMods, StatModValues);
			for (i = 0; i < StatMods.Length; ++i)
			{
				AddModifier(int(StatModValues[i]), StatMods[i].GetX2Effect().FriendlyName, eHit_Crit);
			}
			if (bSquadsight)
			{
				AddModifier(default.SQUADSIGHT_CRIT_MOD, class'XLocalizedData'.default.SquadsightMod, eHit_Crit);
			}

			if (SourceWeapon !=  none)
			{
				AddModifier(SourceWeapon.GetItemCritChance(), class'XLocalizedData'.default.WeaponCritBonus, eHit_Crit);
			}
			if (bFlanking && !bMeleeAttack)
			{
				if (`XENGINE.IsMultiplayerGame())
				{
					AddModifier(default.MP_FLANKING_CRIT_BONUS, class'XLocalizedData'.default.FlankingCritBonus, eHit_Crit);
				}				
				else
				{
					AddModifier(UnitState.GetCurrentStat(eStat_FlankingCritChance), class'XLocalizedData'.default.FlankingCritBonus, eHit_Crit);
				}
			}
		}
		foreach UnitState.AffectedByEffects(EffectRef)
		{
			EffectModifiers.Length = 0;
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			PersistentEffect = EffectState.GetX2Effect();
			if (UniqueToHitEffects.Find(PersistentEffect) != INDEX_NONE)
				continue;

			PersistentEffect.GetToHitModifiers(EffectState, UnitState, TargetState, kAbility, self.Class, bMeleeAttack, bFlanking, bIndirectFire, EffectModifiers);
			if (EffectModifiers.Length > 0)
			{
				if (PersistentEffect.UniqueToHitModifiers())
					UniqueToHitEffects.AddItem(PersistentEffect);

				for (i = 0; i < EffectModifiers.Length; ++i)
				{
					if (!bAllowCrit && EffectModifiers[i].ModType == eHit_Crit)
					{
						if (!PersistentEffect.AllowCritOverride())
							continue;
					}
					AddModifier(EffectModifiers[i].Value, EffectModifiers[i].Reason, EffectModifiers[i].ModType);
				}
			}
			if (PersistentEffect.ShotsCannotGraze())
			{
				bIgnoreGraze = true;
				IgnoreGrazeReason = PersistentEffect.FriendlyName;
			}
		}
		UniqueToHitEffects.Length = 0;
		if (TargetState.AffectedByEffects.Length > 0)
		{
			foreach TargetState.AffectedByEffects(EffectRef)
			{
				EffectModifiers.Length = 0;
				EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
				PersistentEffect = EffectState.GetX2Effect();
				if (UniqueToHitEffects.Find(PersistentEffect) != INDEX_NONE)
					continue;

				PersistentEffect.GetToHitAsTargetModifiers(EffectState, UnitState, TargetState, kAbility, self.Class, bMeleeAttack, bFlanking, bIndirectFire, EffectModifiers);
				if (EffectModifiers.Length > 0)
				{
					if (PersistentEffect.UniqueToHitAsTargetModifiers())
						UniqueToHitEffects.AddItem(PersistentEffect);

					for (i = 0; i < EffectModifiers.Length; ++i)
					{
						if (!bAllowCrit && EffectModifiers[i].ModType == eHit_Crit)
							continue;
						AddModifier(EffectModifiers[i].Value, EffectModifiers[i].Reason, EffectModifiers[i].ModType);
					}
				}
	
				// XModBase: Check for crit immunity.			
				XModBaseEffect = X2Effect_XModBase(PersistentEffect);
				if (XModBaseEffect != none)
				{
					if (XModBaseEffect.CannotBeCrit(kAbility, UnitState, TargetState))
					{
						bIgnoreCrit = true;
						IgnoreCritReason = PersistentEffect.FriendlyName;
					}
				}
			}
		}
		//  Remove graze if shooter ignores graze chance.
		if (bIgnoreGraze)
		{
			AddModifier(-m_ShotBreakdown.ResultTable[eHit_Graze], IgnoreGrazeReason, eHit_Graze);
		}
		//  Remove crit if target is immune.
		if (bIgnoreCrit)
		{
			AddModifier(-m_ShotBreakdown.ResultTable[eHit_Crit], IgnoreCritReason, eHit_Crit);
		}
		//  Remove crit from reaction fire. Must be done last to remove all crit.
		if (bReactionFire)
		{
			AddReactionCritModifier(UnitState, TargetState);
		}
	}

	//  Final multiplier based on end Success chance
	if (bReactionFire)
	{
		FinalAdjust = m_ShotBreakdown.ResultTable[eHit_Success] * GetReactionAdjust(UnitState, TargetState);
		AddModifier(-int(FinalAdjust), AbilityTemplate.LocFriendlyName);
		AddReactionFlatModifier(UnitState, TargetState);
	}
	else if (FinalMultiplier != 1.0f)
	{
		FinalAdjust = m_ShotBreakdown.ResultTable[eHit_Success] * FinalMultiplier;
		AddModifier(-int(FinalAdjust), AbilityTemplate.LocFriendlyName);
	}

	// XModBase: Apply final modifiers. These can read the whole shot breakdown. To avoid ordering 
	// issues with them reading the breakdown, we collect all the modifiers first and then apply 
	// them together.
	FinalEffectModifiers.Length = 0;
	UniqueToHitEffects.Length = 0;
	foreach UnitState.AffectedByEffects(EffectRef)
	{
		EffectModifiers.Length = 0;
		EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
		PersistentEffect = EffectState.GetX2Effect();
		if (UniqueToHitEffects.Find(PersistentEffect) != INDEX_NONE)
			continue;

		XModBaseEffect = X2Effect_XModBase(PersistentEffect);
		if (XModBaseEffect != none)
		{
			XModBaseEffect.GetFinalToHitModifiers(EffectState, UnitState, TargetState, kAbility, self.Class, bMeleeAttack, bFlanking, bIndirectFire, m_ShotBreakdown, EffectModifiers);
			if (EffectModifiers.Length > 0)
			{
				if (PersistentEffect.UniqueToHitAsTargetModifiers())
					UniqueToHitEffects.AddItem(PersistentEffect);

				for (i = 0; i < EffectModifiers.Length; ++i)
				{
					FinalEffectModifiers.AddItem(EffectModifiers[i]);
				}
			}
		}
	}
	for (i = 0; i < FinalEffectModifiers.Length; ++i)
	{
		AddModifier(FinalEffectModifiers[i].Value, FinalEffectModifiers[i].Reason, FinalEffectModifiers[i].ModType);
	}

	FinalizeHitChance();
	m_bDebugModifiers = false;
	return m_ShotBreakdown.FinalHitChance;
}

// Copied from X2AbilityToHitCalc and modified.
function InternalRollForAbilityHit(XComGameState_Ability kAbility, AvailableTarget kTarget, const out AbilityResultContext ResultContext, out EAbilityHitResult Result, out ArmorMitigationResults ArmorMitigated, out int HitChance)
{
	local int i, RandRoll, Current, ModifiedHitChance, Luck;
	local EAbilityHitResult DebugResult, ChangeResult;
	local ArmorMitigationResults Armor;
	local XComGameState_Unit TargetState, UnitState;
	local XComGameState_Player PlayerState;
	local XComGameStateHistory History;
	local StateObjectReference EffectRef;
	local XComGameState_Effect EffectState;
	local X2Effect_XModBase	XModBaseEffect;
	local bool bRolledResultIsAMiss, bModHitRoll;
	local bool HitsAreCrits;
	local string LogMsg;

	History = `XCOMHISTORY;

	`log("===" $ GetFuncName() $ "===", true, 'XCom_HitRolls');
	`log("Attacker ID:" @ kAbility.OwnerStateObject.ObjectID, true, 'XCom_HitRolls');
	`log("Target ID:" @ kTarget.PrimaryTarget.ObjectID, true, 'XCom_HitRolls');
	`log("Ability:" @ kAbility.GetMyTemplate().LocFriendlyName @ "(" $ kAbility.GetMyTemplateName() $ ")", true, 'XCom_HitRolls');

	ArmorMitigated = Armor;     //  clear out fields just in case
	HitsAreCrits = bHitsAreCrits;
	if (`CHEATMGR != none)
	{
		if (`CHEATMGR.bForceCritHits)
			HitsAreCrits = true;

		if (`CHEATMGR.bNoLuck)
		{
			`log("NoLuck cheat forcing a miss.", true, 'XCom_HitRolls');
			Result = eHit_Miss;			
			return;
		}
		if (`CHEATMGR.bDeadEye)
		{
			`log("DeadEye cheat forcing a hit.", true, 'XCom_HitRolls');
			Result = eHit_Success;
			if (HitsAreCrits)
				Result = eHit_Crit;
			return;
		}
	}

	HitChance = GetHitChance(kAbility, kTarget, true);
	RandRoll = `SYNC_RAND_TYPED(100, ESyncRandType_Generic);
	Result = eHit_Miss;

	`log("=" $ GetFuncName() $ "=", true, 'XCom_HitRolls');
	`log("Final hit chance:" @ HitChance, true, 'XCom_HitRolls');
	`log("Random roll:" @ RandRoll, true, 'XCom_HitRolls');
	//  GetHitChance fills out m_ShotBreakdown and its ResultTable
	for (i = 0; i < eHit_Miss; ++i)     //  If we don't match a result before miss, then it's a miss.
	{
		Current += m_ShotBreakdown.ResultTable[i];
		DebugResult = EAbilityHitResult(i);
		`log("Checking table" @ DebugResult @ "(" $ Current $ ")...", true, 'XCom_HitRolls');
		if (RandRoll < Current)
		{
			Result = EAbilityHitResult(i);
			`log("MATCH!", true, 'XCom_HitRolls');
			break;
		}
	}	
	if (HitsAreCrits && Result == eHit_Success)
		Result = eHit_Crit;

	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	TargetState = XComGameState_Unit(History.GetGameStateForObjectID(kTarget.PrimaryTarget.ObjectID));
	
	// Aim Assist (miss streak prevention)
	bRolledResultIsAMiss = class'XComGameStateContext_Ability'.static.IsHitResultMiss(Result);

	ModifiedHitChance = HitChance;
		
	if( UnitState != None && !bReactionFire )           //  reaction fire shots do not get adjusted for difficulty
	{
		PlayerState = XComGameState_Player(History.GetGameStateForObjectID(UnitState.GetAssociatedPlayerID()));
		
		if( bRolledResultIsAMiss && PlayerState.GetTeam() == eTeam_XCom )
		{
			ModifiedHitChance = GetModifiedHitChanceForCurrentDifficulty(PlayerState, HitChance);

			if( RandRoll < ModifiedHitChance )
			{
				`log("*** AIM ASSIST forcing an XCom MISS to become a HIT!", true, 'XCom_HitRolls');
			}
		}
		else if( !bRolledResultIsAMiss && PlayerState.GetTeam() == eTeam_Alien )
		{
			ModifiedHitChance = GetModifiedHitChanceForCurrentDifficulty(PlayerState, HitChance);

			if( RandRoll >= ModifiedHitChance )
			{
				`log("*** AIM ASSIST forcing an Alien HIT to become a MISS!", true, 'XCom_HitRolls');
			}
		}
	}

	// XModBase: This calculates unit luck and adds it to the aim assist modifier.
	if (UnitState != none && TargetState != none)
	{
		foreach UnitState.AffectedByEffects(EffectRef)
		{
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			if (EffectState != none)
			{
				XModBaseEffect = X2Effect_XModBase(EffectState.GetX2Effect());
				if (XModBaseEffect != none)
				{
					Luck += XModBaseEffect.GetLuckModifier(EffectState, UnitState, TargetState, kAbility, Result);
				}
			}
		}
	}

	// XModBase: Luck can't more than double the hit chance or double the miss chance
	Luck = Clamp(Luck, (HitChance - 100) * 2, HitChance * 2);

	ModifiedHitChance += Luck;

	// XModBase: Change the result if necessary.
	if (bRolledResultIsAMiss && RandRoll < ModifiedHitChance)
	{
		Result = eHit_Success;
		bModHitRoll = true;
		`log("*** AIM ASSIST or LUCK forcing a MISS to become a HIT!", true, 'XCom_HitRolls');
	}
	else if (!bRolledResultIsAMiss && RandRoll >= ModifiedHitChance)
	{
		Result = eHit_Miss;
		bModHitRoll = true;
		`log("*** AIM ASSIST or LUCK forcing a HIT to become a MISS!", true, 'XCom_HitRolls');
	}

	if (UnitState != none && TargetState != none)
	{
		foreach UnitState.AffectedByEffects(EffectRef)
		{
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
			if (EffectState != none)
			{
				if (EffectState.GetX2Effect().ChangeHitResultForAttacker(UnitState, TargetState, kAbility, Result, ChangeResult))
				{
					`log("Effect" @ EffectState.GetX2Effect().FriendlyName @ "changing hit result for attacker:" @ ChangeResult,true,'XCom_HitRolls');
					Result = ChangeResult;
				}
			}
		}
	}
	
	`log("***HIT" @ Result, !bRolledResultIsAMiss, 'XCom_HitRolls');
	`log("***MISS" @ Result, bRolledResultIsAMiss, 'XCom_HitRolls');

	//  add armor mitigation (regardless of hit/miss as some shots deal damage on a miss)	
	if (TargetState != none)
	{
		//  Check for Lightning Reflexes
		if (bReactionFire && TargetState.bLightningReflexes && !bRolledResultIsAMiss)
		{
			Result = eHit_LightningReflexes;
			`log("Lightning Reflexes triggered! Shot will miss.", true, 'XCom_HitRolls');
		}

		class'X2AbilityArmorHitRolls'.static.RollArmorMitigation(m_ShotBreakdown.ArmorMitigation, ArmorMitigated, TargetState);
	}	

	if (UnitState != none && TargetState != none)
	{
		LogMsg = class'XLocalizedData'.default.StandardAimLogMsg;
		LogMsg = repl(LogMsg, "#Shooter", UnitState.GetName(eNameType_RankFull));
		LogMsg = repl(LogMsg, "#Target", TargetState.GetName(eNameType_RankFull));
		LogMsg = repl(LogMsg, "#Ability", kAbility.GetMyTemplate().LocFriendlyName);
		LogMsg = repl(LogMsg, "#Chance", bModHitRoll ? ModifiedHitChance : HitChance);
		LogMsg = repl(LogMsg, "#Roll", RandRoll);
		LogMsg = repl(LogMsg, "#Result", class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[Result]);
		`COMBATLOG(LogMsg);
	}
}
