#===============================================================================
# Toxic Sludge
#===============================================================================
Battle::AbilityEffects::OnSwitchIn.add(:TOXICSLUDGE,
  proc { |ability,battler,battle|
  battle.pbShowAbilitySplash(battler)
  battle.pbDisplay(_INTL("{1}'s {2} is pouring onto the battlefield!", battler.pbThis,battler.abilityName))
  battle.eachOtherSideBattler(battler.index) do |b|
    next if !b.near?(battler)
    if b.pbCanPoison?(battler,Battle::Scene::USE_ABILITY_SPLASH)
      msg = nil
    if !Battle::Scene::USE_ABILITY_SPLASH
      msg = _INTL("{1}'s {2} spilled and poisoned the foe.",
    battler.pbThis,battler.abilityName)
    end
    b.pbPoison(msg)
    end
    battle.pbHideAbilitySplash(battler)
  end
  }
)


#===============================================================================
# Ethereal
#===============================================================================
Battle::AbilityEffects::MoveImmunity.add(:ETHEREAL,
  proc { |ability, user, target, move, type, battle, show_message|
    next false if !move.contactMove?
    if show_message
      battle.pbShowAbilitySplash(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           target.pbThis, target.abilityName, move.name))
      end
      battle.pbHideAbilitySplash(target)
    end
    next true
  }
)


#===============================================================================
# Vocal Harmony
#===============================================================================
Battle::AbilityEffects::ModifyMoveBaseType.add(:VOCALHARMONY,
  proc { |ability, user, move, type|
    next :FAIRY if GameData::Type.exists?(:FAIRY) && move.soundMove?
  }
)


#===============================================================================
# Wind Down
#===============================================================================
Battle::AbilityEffects::EndOfRoundEffect.add(:WINDDOWN,
  proc { |ability, battler, battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount > 0 && battle.choices[battler.index][0] != :Run &&
       battler.pbCanLowerStatStage?(:ATTACK, battler)
      battler.pbLowerStatStageByAbility(:ATTACK, 1, battler)
       battler.pbCanLowerStatStage?(:SPECIAL_ATTACK, battler)
      battler.pbLowerStatStageByAbility(:SPECIAL_ATTACK, 1, battler)
       battler.pbCanLowerStatStage?(:DEFENSE, battler)
      battler.pbLowerStatStageByAbility(:DEFENSE, 1, battler)
       battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE, battler)
      battler.pbLowerStatStageByAbility(:SPECIAL_DEFENSE, 1, battler)
       battler.pbCanLowerStatStage?(:SPEED, battler)
      battler.pbLowerStatStageByAbility(:SPEED, 1, battler)
    end
  }
)

#===============================================================================
# Tremor
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:TREMOR,
  proc { |ability, user, target, move, mults, power, type|
    if user.hp <= user.totalhp / 3 && type == :GROUND
      mults[:attack_multiplier] *= 1.5
    end
  }
)

#===============================================================================
# Permafrost
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:PERMAFROST,
  proc { |ability, user, target, move, mults, power, type|
    if user.hp <= user.totalhp / 3 && type == :ICE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

#===============================================================================
# Refinery
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:REFINERY,
  proc { |ability, user, target, move, mults, power, type|
    if user.hp <= user.totalhp / 3 && type == :STEEL
      mults[:attack_multiplier] *= 1.5
    end
  }
)

#===============================================================================
# Bulk Boost
#===============================================================================
Battle::AbilityEffects::EndOfRoundEffect.add(:BULKBOOST,
  proc { |ability, battler, battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount > 0 && battle.choices[battler.index][0] != :Run &&
       battler.pbCanRaiseStatStage?(:ATTACK, battler)
      battler.pbRaiseStatStageByAbility(:ATTACK, 1, battler)
    end
  }
)

#===============================================================================
# Power of Teamwork
#===============================================================================
Battle::AbilityEffects::OnSwitchIn.add(:POWEROFTEAMWORK,
  proc { |ability, battler, battle, switch_in|
    if battler.allAllies.any? { |b| b.hasActiveAbility?([:POWEROFTEAMWORK]) }
      battler.pbCanRaiseStatStage?(:ATTACK, battler)
      battler.pbRaiseStatStageByAbility(:ATTACK, 1, battler)
      battler.pbCanRaiseStatStage?(:SPEED, battler)
      battler.pbRaiseStatStageByAbility(:SPEED, 1, battler)
      battle.pbDisplay(_INTL("{1} is powered up by from the help of its allies!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    end
  }
)

#===============================================================================
# Parasite
#===============================================================================
Battle::AbilityEffects::OnBeingHit.add(:PARASITE,
 proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.unstoppableAbility? || user.ability == ability
    oldAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(Battle::Scene::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
      user.ability = ability
      battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} contracted a {2} from {3}!", user.pbThis, user.abilityName, target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis, user.abilityName, target.pbThis(true)))
      end
      battle.pbHideAbilitySplash(user) if user.opposes?(target)
      next if user.poisoned?
        user.pbPoison(target)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnLosingAbility(oldAbil)
    user.pbTriggerAbilityOnGainingIt
  }
)

#===============================================================================
# Half-Drake
#===============================================================================
Battle::AbilityEffects::OnSwitchIn.add(:HALFDRAKE,
  proc { |ability, battler, battle, switch_in|
    next if battler.effects[PBEffects::ExtraType] == :DRAGON

    battle.pbShowAbilitySplash(battler)

    battler.effects[PBEffects::ExtraType] = :DRAGON
    typeName = GameData::Type.get(:DRAGON).name
    battle.pbDisplay(_INTL("{1} became a {2}-type!", battler.pbThis, typeName))

    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# Readied Action
# Doubles Attack on the first turn the Pokémon is out
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:READIEDACTION,
  proc { |ability, user, target, move, mults, power, type|
    if move.physicalMove? && user.turnCount <= 1
      mults[:attack_multiplier] *= 2 
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:READIEDACTION,
  proc { |ability, battler, battle, mults, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is preparing a powerful attack!", battler.pbThis, battler.abilityName))
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# Slapstick
# Raises all stats by one when hit with a physical move
#===============================================================================
Battle::AbilityEffects::OnBeingHit.add(:SLAPSTICK,
  proc { |ability, user, target, move, battle|
    target.pbRaiseStatStageByAbility(:DEFENSE, 1, target)
    target.pbRaiseStatStageByAbility(:ATTACK, 1, target)
    target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, target)
    target.pbRaiseStatStageByAbility(:SPEED, 1, target)
    target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 1, target)
    target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE, 1, target)
  }
)

#===============================================================================
# Grass Muncher
#===============================================================================
Battle::AbilityEffects::MoveImmunity.add(:GRASSMUNCHER,
  proc { |ability, user, target, move, type, battle, show_message|
    next target.pbMoveImmunityHealingAbility(user, move, type, :GRASS, show_message)
  }
)