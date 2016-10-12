class X2Ability_BO extends X2Ability;

function TypicalAbility_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{		
	local X2AbilityTemplate             AbilityTemplate;
	local XComGameStateContext_Ability  Context, InterruptContext;
	local AbilityInputContext           AbilityContext;
	local StateObjectReference          ShootingUnitRef;	
	local X2Action                      AddedAction;
	local XComGameState_BaseObject      TargetStateObject;//Container for state objects within VisualizeGameState	
	local XComGameState_Item            SourceWeapon;
	local X2GrenadeTemplate             GrenadeTemplate;
	local X2AmmoTemplate                AmmoTemplate;
	local X2WeaponTemplate              WeaponTemplate;
	local array<X2Effect>               MultiTargetEffects;
	local bool							bSourceIsAlsoTarget;
	local bool							bMultiSourceIsAlsoTarget;
	
	local Actor                     TargetVisualizer, ShooterVisualizer;
	local X2VisualizerInterface     TargetVisualizerInterface, ShooterVisualizerInterface;
	local int                       EffectIndex, TargetIndex;
	local XComGameState_EnvironmentDamage EnvironmentDamageEvent;
	local XComGameState_WorldEffectTileData WorldDataUpdate;

	local VisualizationTrack        EmptyTrack;
	local VisualizationTrack        BuildTrack;
	local VisualizationTrack        SourceTrack, InterruptTrack;
	local int						TrackIndex;
	local bool						bAlreadyAdded, bInterruptTrackAlreadyAdded;
	local XComGameStateHistory      History;
	local X2Action_MoveTurn         MoveTurnAction;

	local XComGameStateContext_Ability CounterAttackContext;
	local X2AbilityTemplate			CounterattackTemplate;
	local array<VisualizationTrack> OutCounterattackVisualizationTracks;
	local int						ActionIndex;

	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;
	local name         ApplyResult;

	local XComGameState_InteractiveObject InteractiveObject;
	local XComGameState_Ability     AbilityState;
	local XComGameState InterruptState;
	local X2Action_SendInterTrackMessage InterruptMsg;
	local X2Action FoundAction;
	local X2Action_WaitForAbilityEffect WaitAction;
	local bool bInterruptPath;

	local X2Action_ExitCover ExitCoverAction;
	local X2Action_Delay MoveDelay;
		
	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.AbilityRef.ObjectID));
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	ShootingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter, part I. We split this into two parts since
	//in some situations the shooter can also be a target
	//****************************************************************************************
	ShooterVisualizer = History.GetVisualizer(ShootingUnitRef.ObjectID);
	ShooterVisualizerInterface = X2VisualizerInterface(ShooterVisualizer);

	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	if (SourceTrack.StateObject_NewState == none)
		SourceTrack.StateObject_NewState = SourceTrack.StateObject_OldState;
	SourceTrack.TrackActor = ShooterVisualizer;

	SourceTrack.AbilityName = AbilityTemplate.DataName;

	SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(AbilityContext.ItemObject.ObjectID));
	if (SourceWeapon != None)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		AmmoTemplate = X2AmmoTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));
	}
	if(AbilityTemplate.bShowPostActivation)
	{
		//Show the text flyover at the end of the visualization after the camera pans back
		Context.PostBuildVisualizationFn.AddItem(ActivationFlyOver_PostBuildVisualization);
	}
	if (AbilityTemplate.bShowActivation || AbilityTemplate.ActivationSpeech != '')
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(SourceTrack, Context));

		if (SourceWeapon != None)
		{
			// Shadow Ops: Use grenade-specific sound cue for launched grenades.
			if (AbilityTemplate.bUseLaunchedGrenadeEffects)
			{
				GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));

				// Use launch sound cue instead of throw except for smoke/flashbang
				if (GrenadeTemplate != none && (GrenadeTemplate.OnThrowBarkSoundCue == 'ThrowGrenade' ||
												GrenadeTemplate.OnThrowBarkSoundCue == ''))
				{
					GrenadeTemplate = none;
				}
			}
			else
			{
				GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetMyTemplate());
			}
		}

		if (GrenadeTemplate != none)
		{
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", GrenadeTemplate.OnThrowBarkSoundCue, eColor_Good);
		}
		else
		{
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.bShowActivation ? AbilityTemplate.LocFriendlyName : "", AbilityTemplate.ActivationSpeech, eColor_Good, AbilityTemplate.bShowActivation ? AbilityTemplate.IconImage : "");
		}
	}

	if( Context.IsResultContextMiss() && AbilityTemplate.SourceMissSpeech != '' )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.SourceMissSpeech, eColor_Bad);
	}
	else if( Context.IsResultContextHit() && AbilityTemplate.SourceHitSpeech != '' )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", AbilityTemplate.SourceHitSpeech, eColor_Good);
	}

	if (!AbilityTemplate.bSkipFireAction)
	{
		ExitCoverAction = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTrack(SourceTrack, Context));
		ExitCoverAction.bSkipExitCoverVisualization = AbilityTemplate.bSkipExitCoverWhenFiring;

		// if this ability has a built in move, do it right before we do the fire action
		if(Context.InputContext.MovementPaths.Length > 0)
		{
			if (Context.InterruptionStatus == eInterruptionStatus_Resume)
			{				
				//  Look for the interrupting state and fill in its visualization
			    InterruptState = Context.GetFirstStateInInterruptChain();
				if (InterruptState != None)
				{
					while (InterruptState != None)
					{
						InterruptContext = XComGameStateContext_Ability(InterruptState.GetContext());
						if (InterruptContext != none && InterruptContext.InterruptionStatus == eInterruptionStatus_None)
						{
							if (InterruptContext.InputContext.PrimaryTarget.ObjectID == ShootingUnitRef.ObjectID)
								break;
						}
						InterruptState = InterruptState.GetContext().GetNextStateInEventChain();
						InterruptContext = None;
					}
					if (InterruptContext != None)
					{				
						CounterattackTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(InterruptContext.InputContext.AbilityTemplateName);
						if ((Context.ResultContext.HitResult != eHit_CounterAttack) && CounterattackTemplate.IsMelee())        //  an interrupt during the move should be fine, only need special handling for end of move interruption prior to the attack
						{
							bInterruptPath = true;
							class'X2VisualizerHelpers'.static.ParsePath(Context, SourceTrack, OutVisualizationTracks, false);
							CounterattackTemplate.BuildVisualizationFn(InterruptState, OutCounterattackVisualizationTracks);
				
							InterruptMsg = X2Action_SendInterTrackMessage(class'X2Action_SendInterTrackMessage'.static.AddToVisualizationTrack(SourceTrack, Context));
							InterruptMsg.SendTrackMessageToRef = InterruptContext.InputContext.SourceObject;

							for (TrackIndex = 0; TrackIndex < OutCounterattackVisualizationTracks.Length; ++TrackIndex)
							{
								if(OutCounterattackVisualizationTracks[TrackIndex].StateObject_OldState.ObjectID == SourceTrack.StateObject_OldState.ObjectID)
								{
									for(ActionIndex = 0; ActionIndex < OutCounterattackVisualizationTracks[TrackIndex].TrackActions.Length; ++ActionIndex)
									{
										SourceTrack.TrackActions.AddItem(OutCounterattackVisualizationTracks[TrackIndex].TrackActions[ActionIndex]);
									}
								}
								else
								{
									if (OutCounterattackVisualizationTracks[TrackIndex].StateObject_NewState.ObjectID == InterruptContext.InputContext.SourceObject.ObjectID &&
										InterruptTrack == EmptyTrack)
									{
										InterruptTrack = OutCounterattackVisualizationTracks[TrackIndex];

										if(`XCOMVISUALIZATIONMGR.TrackHasActionOfType(OutCounterattackVisualizationTracks[TrackIndex], class'X2Action_EnterCover', FoundAction))
										{
											X2Action_EnterCover(FoundAction).bInstantEnterCover = true;
										}

										AddedAction = class'X2Action'.static.CreateVisualizationActionClass(class'X2Action_WaitForAbilityEffect', InterruptContext, InterruptTrack.TrackActor);
										OutCounterattackVisualizationTracks[TrackIndex].TrackActions.InsertItem(0, AddedAction);
										WaitAction = X2Action_WaitForAbilityEffect(class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(InterruptTrack, InterruptContext));
										WaitAction.bWaitingForActionMessage = true;
									}

									OutVisualizationTracks.AddItem(OutCounterattackVisualizationTracks[TrackIndex]);
								}
							}
							OutCounterattackVisualizationTracks.Length = 0;
							`XCOMVISUALIZATIONMGR.SkipVisualization(InterruptState.HistoryIndex);

							class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(SourceTrack, Context);
						}
					}
				}
			}
			if (!bInterruptPath)
			{
				// note that we skip the stop animation since we'll be doing our own stop with the end of move attack
				class'X2VisualizerHelpers'.static.ParsePath(Context, SourceTrack, OutVisualizationTracks, AbilityTemplate.bSkipMoveStop);

				//  add paths for other units moving with us (e.g. gremlins moving with a move+attack ability)
				if (Context.InputContext.MovementPaths.Length > 1)
				{
					for (TrackIndex = 1; TrackIndex < Context.InputContext.MovementPaths.Length; ++TrackIndex)
					{
						BuildTrack = EmptyTrack;
						BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(Context.InputContext.MovementPaths[TrackIndex].MovingUnitRef.ObjectID);
						BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(Context.InputContext.MovementPaths[TrackIndex].MovingUnitRef.ObjectID);
						MoveDelay = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTrack(BuildTrack, Context));
						MoveDelay.Duration = class'X2Ability_DefaultAbilitySet'.default.TypicalMoveDelay;
						class'X2VisualizerHelpers'.static.ParsePath(Context, BuildTrack, OutVisualizationTracks, AbilityTemplate.bSkipMoveStop);						
						OutVisualizationTracks.AddItem(BuildTrack);
					}
				}
			}

			// add our fire action
			AddedAction = AbilityTemplate.ActionFireClass.static.AddToVisualizationTrack(SourceTrack, Context);
			
			if (!bInterruptPath)
			{
				// swap the fire action for the end move action, so that we trigger it just before the end. This sequences any moving fire action
				// correctly so that it blends nicely before the move end.
				for (TrackIndex = 0; TrackIndex < SourceTrack.TrackActions.Length; ++TrackIndex)
				{
					if (X2Action_MoveEnd(SourceTrack.TrackActions[TrackIndex]) != none)
					{
						break;
					}
				}
				if(TrackIndex >= SourceTrack.TrackActions.Length)
				{
					`Redscreen("X2Action_MoveEnd not found when building Typical Ability path. @gameplay @dburchanowski @jbouscher");
				}
				else
				{
					SourceTrack.TrackActions[TrackIndex + 1] = SourceTrack.TrackActions[TrackIndex];
					SourceTrack.TrackActions[TrackIndex] = AddedAction;
				}
			}
			else
			{
				//  prompt the target to play their hit reacts after the attack
				InterruptMsg = X2Action_SendInterTrackMessage(class'X2Action_SendInterTrackMessage'.static.AddToVisualizationTrack(SourceTrack, Context));
				InterruptMsg.SendTrackMessageToRef = InterruptContext.InputContext.SourceObject;
			}
		}
		else
		{
			// no move, just add the fire action
			AddedAction = AbilityTemplate.ActionFireClass.static.AddToVisualizationTrack(SourceTrack, Context);
		}

		if( AbilityTemplate.AbilityToHitCalc != None )
		{
			X2Action_Fire(AddedAction).SetFireParameters( Context.IsResultContextHit() );
		}

		//Process a potential counter attack from the target here
		if (Context.ResultContext.HitResult == eHit_CounterAttack)
		{
			CounterAttackContext = class'X2Ability'.static.FindCounterAttackGameState(Context, XComGameState_Unit(SourceTrack.StateObject_OldState));
			if (CounterAttackContext != none)
			{
				//Entering this code block means that we were the target of a counter attack to our original attack. Here, we look forward in the history
				//and append the necessary visualization tracks so that the counter attack can happen visually as part of our original attack.

				//Get the ability template for the counter attack against us
				CounterattackTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(CounterAttackContext.InputContext.AbilityTemplateName);
				CounterattackTemplate.BuildVisualizationFn(CounterAttackContext.AssociatedState, OutCounterattackVisualizationTracks);

				//Take the visualization actions from the counter attack game state ( where we are the target )
				for(TrackIndex = 0; TrackIndex < OutCounterattackVisualizationTracks.Length; ++TrackIndex)
				{
					if(OutCounterattackVisualizationTracks[TrackIndex].StateObject_OldState.ObjectID == SourceTrack.StateObject_OldState.ObjectID)
					{
						for(ActionIndex = 0; ActionIndex < OutCounterattackVisualizationTracks[TrackIndex].TrackActions.Length; ++ActionIndex)
						{
							//Don't include waits
							if(!OutCounterattackVisualizationTracks[TrackIndex].TrackActions[ActionIndex].IsA('X2Action_WaitForAbilityEffect'))
							{
								SourceTrack.TrackActions.AddItem(OutCounterattackVisualizationTracks[TrackIndex].TrackActions[ActionIndex]);
							}
						}
						break;
					}
				}
				
				//Notify the visualization mgr that the counter attack visualization is taken care of, so it can be skipped
				`XCOMVISUALIZATIONMGR.SkipVisualization(CounterAttackContext.AssociatedState.HistoryIndex);
			}
		}
	}

	//If there are effects added to the shooter, add the visualizer actions for them
	for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
	{
		AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, SourceTrack, Context.FindShooterEffectApplyResult(AbilityTemplate.AbilityShooterEffects[EffectIndex]));		
	}
	//****************************************************************************************

	//Configure the visualization track for the target(s). This functionality uses the context primarily
	//since the game state may not include state objects for misses.
	//****************************************************************************************	
	bSourceIsAlsoTarget = AbilityContext.PrimaryTarget.ObjectID == AbilityContext.SourceObject.ObjectID; //The shooter is the primary target
	if (AbilityTemplate.AbilityTargetEffects.Length > 0 &&			//There are effects to apply
		AbilityContext.PrimaryTarget.ObjectID > 0)				//There is a primary target
	{
		TargetVisualizer = History.GetVisualizer(AbilityContext.PrimaryTarget.ObjectID);
		TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);

		if( bSourceIsAlsoTarget )
		{
			BuildTrack = SourceTrack;
		}
		else
		{
			BuildTrack = InterruptTrack;        //  interrupt track will either be empty or filled out correctly
		}

		BuildTrack.TrackActor = TargetVisualizer;

		TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
		if( TargetStateObject != none )
		{
			History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.PrimaryTarget.ObjectID, 
															   BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState,
															   eReturnType_Reference,
															   VisualizeGameState.HistoryIndex);
			`assert(BuildTrack.StateObject_NewState == TargetStateObject);
		}
		else
		{
			//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
			//and show no change.
			BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
			BuildTrack.StateObject_NewState = BuildTrack.StateObject_OldState;
		}

		// if this is a melee attack, make sure the target is facing the location he will be melee'd from
		if(!AbilityTemplate.bSkipFireAction 
			&& !bSourceIsAlsoTarget 
			&& AbilityContext.MovementPaths.Length > 0
			&& AbilityContext.MovementPaths[0].MovementData.Length > 0
			&& XGUnit(TargetVisualizer) != none)
		{
			MoveTurnAction = X2Action_MoveTurn(class'X2Action_MoveTurn'.static.AddToVisualizationTrack(BuildTrack, Context));
			MoveTurnAction.m_vFacePoint = AbilityContext.MovementPaths[0].MovementData[AbilityContext.MovementPaths[0].MovementData.Length - 1].Position;
			MoveTurnAction.m_vFacePoint.Z = TargetVisualizerInterface.GetTargetingFocusLocation().Z;
			MoveTurnAction.UpdateAimTarget = true;
		}

		//Make the target wait until signaled by the shooter that the projectiles are hitting
		if (!AbilityTemplate.bSkipFireAction && !bSourceIsAlsoTarget)
		{
			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context);
		}
		
		//Add any X2Actions that are specific to this effect being applied. These actions would typically be instantaneous, showing UI world messages
		//playing any effect specific audio, starting effect specific effects, etc. However, they can also potentially perform animations on the 
		//track actor, so the design of effect actions must consider how they will look/play in sequence with other effects.
		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			ApplyResult = Context.FindTargetEffectApplyResult(AbilityTemplate.AbilityTargetEffects[EffectIndex]);

			// Target effect visualization
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, ApplyResult);

			// Source effect visualization
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
		}

		//the following is used to handle Rupture flyover text
		if (XComGameState_Unit(BuildTrack.StateObject_OldState).GetRupturedValue() == 0 &&
			XComGameState_Unit(BuildTrack.StateObject_NewState).GetRupturedValue() > 0)
		{
			//this is the frame that we realized we've been ruptured!
			class 'X2StatusEffects'.static.RuptureVisualization(VisualizeGameState, BuildTrack);
		}

		if (AbilityTemplate.bAllowAmmoEffects && AmmoTemplate != None)
		{
			for (EffectIndex = 0; EffectIndex < AmmoTemplate.TargetEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(AmmoTemplate.TargetEffects[EffectIndex]);
				AmmoTemplate.TargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, ApplyResult);
				AmmoTemplate.TargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
			}
		}
		if (AbilityTemplate.bAllowBonusWeaponEffects && WeaponTemplate != none)
		{
			for (EffectIndex = 0; EffectIndex < WeaponTemplate.BonusWeaponEffects.Length; ++EffectIndex)
			{
				ApplyResult = Context.FindTargetEffectApplyResult(WeaponTemplate.BonusWeaponEffects[EffectIndex]);
				WeaponTemplate.BonusWeaponEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, ApplyResult);
				WeaponTemplate.BonusWeaponEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
			}
		}

		if (Context.IsResultContextMiss() && (AbilityTemplate.LocMissMessage != "" || AbilityTemplate.TargetMissSpeech != ''))
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocMissMessage, AbilityTemplate.TargetMissSpeech, eColor_Bad);
		}
		else if( Context.IsResultContextHit() && (AbilityTemplate.LocHitMessage != "" || AbilityTemplate.TargetHitSpeech != '') )
		{
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTrack(BuildTrack, Context));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocHitMessage, AbilityTemplate.TargetHitSpeech, eColor_Good);
		}

		if( TargetVisualizerInterface != none )
		{
			//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
			TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildTrack);
		}

		if (!bSourceIsAlsoTarget && BuildTrack.TrackActions.Length > 0)
		{
			OutVisualizationTracks.AddItem(BuildTrack);
		}

		if( bSourceIsAlsoTarget )
		{
			SourceTrack = BuildTrack;
		}
	}

	if (AbilityTemplate.bUseLaunchedGrenadeEffects)
	{
		MultiTargetEffects = X2GrenadeTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState)).LaunchedGrenadeEffects;
	}
	else if (AbilityTemplate.bUseThrownGrenadeEffects)
	{
		MultiTargetEffects = X2GrenadeTemplate(SourceWeapon.GetMyTemplate()).ThrownGrenadeEffects;
	}
	else
	{
		MultiTargetEffects = AbilityTemplate.AbilityMultiTargetEffects;
	}

	//  Apply effects to multi targets
	if( MultiTargetEffects.Length > 0 && AbilityContext.MultiTargets.Length > 0)
	{
		for( TargetIndex = 0; TargetIndex < AbilityContext.MultiTargets.Length; ++TargetIndex )
		{	
			bMultiSourceIsAlsoTarget = false;
			if( AbilityContext.MultiTargets[TargetIndex].ObjectID == AbilityContext.SourceObject.ObjectID )
			{
				bMultiSourceIsAlsoTarget = true;
				bSourceIsAlsoTarget = bMultiSourceIsAlsoTarget;				
			}

			//Some abilities add the same target multiple times into the targets list - see if this is the case and avoid adding redundant tracks
			bAlreadyAdded = false;
			bInterruptTrackAlreadyAdded = false;
			for( TrackIndex = 0; TrackIndex < OutVisualizationTracks.Length; ++TrackIndex )
			{
				if( OutVisualizationTracks[TrackIndex].StateObject_NewState.ObjectID == AbilityContext.MultiTargets[TargetIndex].ObjectID )
				{
					if( (InterruptTrack != EmptyTrack) &&
						(AbilityContext.MultiTargets[TargetIndex].ObjectID == InterruptTrack.StateObject_NewState.ObjectID) &&
						!bInterruptTrackAlreadyAdded )
					{
						// This target may already be in the track due to the fact that it was an interrupting (counterattack)
						// Make sure the MultiTarget effects are applied then.
						// WHEN WE HAVE MORE TIME TO FIX, THIS SHOULD PROBABLY CHECK A LIST AGAINST WHAT HAS BEEN PUT IN BY THE LOOP.
						// THESE TRACKS COULD BE IN THERE FOR OTHER REASONS BESIDES THIS MULTITARGET LOOP.
						bInterruptTrackAlreadyAdded = true;
					}
					else
					{
						bAlreadyAdded = true;
					}
				}
			}

			if( !bAlreadyAdded )
			{
				TargetVisualizer = History.GetVisualizer(AbilityContext.MultiTargets[TargetIndex].ObjectID);
				TargetVisualizerInterface = X2VisualizerInterface(TargetVisualizer);

				if( bMultiSourceIsAlsoTarget )
				{
					BuildTrack = SourceTrack;
				}
				else
				{
					BuildTrack = EmptyTrack;
				}
				BuildTrack.TrackActor = TargetVisualizer;

				TargetStateObject = VisualizeGameState.GetGameStateForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID);
				if( TargetStateObject != none )
				{
					History.GetCurrentAndPreviousGameStatesForObjectID(AbilityContext.MultiTargets[TargetIndex].ObjectID, 
																	   BuildTrack.StateObject_OldState, BuildTrack.StateObject_NewState,
																	   eReturnType_Reference,
																	   VisualizeGameState.HistoryIndex);
					`assert(BuildTrack.StateObject_NewState == TargetStateObject);
				}			
				else
				{
					//If TargetStateObject is none, it means that the visualize game state does not contain an entry for the primary target. Use the history version
					//and show no change.
					BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(AbilityContext.PrimaryTarget.ObjectID);
					BuildTrack.StateObject_NewState = BuildTrack.StateObject_OldState;
				}

				//Make the target wait until signaled by the shooter that the projectiles are hitting
				if (!AbilityTemplate.bSkipFireAction && !bMultiSourceIsAlsoTarget)
				{
					WaitAction = X2Action_WaitForAbilityEffect(class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context));

					if( bInterruptTrackAlreadyAdded &&
						(AbilityContext.MultiTargets[TargetIndex].ObjectID == InterruptTrack.StateObject_NewState.ObjectID) )
					{
						// This is the interrupting track and this wait needs to stop since the interruption would put an earlier
						// wait in.
						// AGAIN, WHEN WE HAVE MORE TIME TO FIX, THIS SHOULD PROBABLY BE MOVED TO THE WAIT ACTION
						// MAKING SURE ANY WAIT IN THE TRACK STOPS.
						WaitAction.bWaitingForActionMessage = true;
					}
				}
		
				//Add any X2Actions that are specific to this effect being applied. These actions would typically be instantaneous, showing UI world messages
				//playing any effect specific audio, starting effect specific effects, etc. However, they can also potentially perform animations on the 
				//track actor, so the design of effect actions must consider how they will look/play in sequence with other effects.
				for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
				{
					ApplyResult = Context.FindMultiTargetEffectApplyResult(MultiTargetEffects[EffectIndex], TargetIndex);

					// Target effect visualization
					MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, ApplyResult);

					// Source effect visualization
					MultiTargetEffects[EffectIndex].AddX2ActionsForVisualizationSource(VisualizeGameState, SourceTrack, ApplyResult);
				}			

				//the following is used to handle Rupture flyover text
				if (XComGameState_Unit(BuildTrack.StateObject_OldState).GetRupturedValue() == 0 &&
					XComGameState_Unit(BuildTrack.StateObject_NewState).GetRupturedValue() > 0)
				{
					//this is the frame that we realized we've been ruptured!
					class 'X2StatusEffects'.static.RuptureVisualization(VisualizeGameState, BuildTrack);
				}

				if( TargetVisualizerInterface != none )
				{
					//Allow the visualizer to do any custom processing based on the new game state. For example, units will create a death action when they reach 0 HP.
					TargetVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, BuildTrack);
				}

				if( !bMultiSourceIsAlsoTarget && BuildTrack.TrackActions.Length > 0 )
				{
					OutVisualizationTracks.AddItem(BuildTrack);
				}

				if( bMultiSourceIsAlsoTarget )
				{
					SourceTrack = BuildTrack;
				}
			}
		}
	}
	//****************************************************************************************

	//Finish adding the shooter's track
	//****************************************************************************************
	if( !bSourceIsAlsoTarget && ShooterVisualizerInterface != none)
	{
		ShooterVisualizerInterface.BuildAbilityEffectsVisualization(VisualizeGameState, SourceTrack);				
	}	

	if (!AbilityTemplate.bSkipFireAction)
	{
		if (!AbilityTemplate.bSkipExitCoverWhenFiring)
		{
			class'X2Action_EnterCover'.static.AddToVisualizationTrack(SourceTrack, Context);
		}
	}
	
	OutVisualizationTracks.AddItem(SourceTrack);
	//****************************************************************************************

	//Configure the visualization tracks for the environment
	//****************************************************************************************
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_EnvironmentDamage', EnvironmentDamageEvent)
	{
		BuildTrack = EmptyTrack;
		BuildTrack.TrackActor = none;
		BuildTrack.StateObject_NewState = EnvironmentDamageEvent;
		BuildTrack.StateObject_OldState = EnvironmentDamageEvent;

		//Wait until signaled by the shooter that the projectiles are hitting
		if (!AbilityTemplate.bSkipFireAction)
			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context);

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');	
		}

		OutVisualizationTracks.AddItem(BuildTrack);
	}

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_WorldEffectTileData', WorldDataUpdate)
	{
		BuildTrack = EmptyTrack;
		BuildTrack.TrackActor = none;
		BuildTrack.StateObject_NewState = WorldDataUpdate;
		BuildTrack.StateObject_OldState = WorldDataUpdate;

		//Wait until signaled by the shooter that the projectiles are hitting
		if (!AbilityTemplate.bSkipFireAction)
			class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context);

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityShooterEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityShooterEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');		
		}

		for (EffectIndex = 0; EffectIndex < AbilityTemplate.AbilityTargetEffects.Length; ++EffectIndex)
		{
			AbilityTemplate.AbilityTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');
		}

		for (EffectIndex = 0; EffectIndex < MultiTargetEffects.Length; ++EffectIndex)
		{
			MultiTargetEffects[EffectIndex].AddX2ActionsForVisualization(VisualizeGameState, BuildTrack, 'AA_Success');	
		}

		OutVisualizationTracks.AddItem(BuildTrack);
	}
	//****************************************************************************************

	//Process any interactions with interactive objects
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_InteractiveObject', InteractiveObject)
	{
		// Add any doors that need to listen for notification
		if (InteractiveObject.IsDoor() && InteractiveObject.HasDestroyAnim()) //Is this a closed door?
		{
			BuildTrack = EmptyTrack;
			//Don't necessarily have a previous state, so just use the one we know about
			BuildTrack.StateObject_OldState = InteractiveObject;
			BuildTrack.StateObject_NewState = InteractiveObject;
			BuildTrack.TrackActor = History.GetVisualizer(InteractiveObject.ObjectID);

			if (!AbilityTemplate.bSkipFireAction)
				class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTrack(BuildTrack, Context);

			class'X2Action_BreakInteractActor'.static.AddToVisualizationTrack(BuildTrack, Context);

			OutVisualizationTracks.AddItem(BuildTrack);
		}
	}
}
