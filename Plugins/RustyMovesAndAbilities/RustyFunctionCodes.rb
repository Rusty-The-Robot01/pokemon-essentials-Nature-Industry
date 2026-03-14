#-----------------------------------------------------------------------------
# Steal Scrap
#-----------------------------------------------------------------------------
class Battle::Move::LowerTargetSpeed1AndUserTakesTargetItem < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't thieve
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if target.wild? && !user.initialItem && target.item == target.initialItem
      user.setInitialItem(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!", user.pbThis, target.pbThis(true), itemName))
    user.pbHeldItemTriggerCheck
    pbAdditionalEffect(user, target)
    if target.pbCanLowerStatStage?(:SPEED, user, self)
      target.pbLowerStatStage(:SPEED, 1, user)
      end
  end
end

#------------------------------------------------------------------------------
#Junk Barrage
#------------------------------------------------------------------------------
class Battle::Move::PoisonFlinchOrDefenseDropTarget < Battle::Move
  def multiHitMove?;            return true; end
  def pbNumHits(user, targets); return 3;    end
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    case @battle.pbRandom(3)
    when 0 then target.pbLowerStatStage(:DEFENSE, 1, user) if target.pbCanLowerStatStage?(:DEFENSE, user, self)
    when 1 then target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    when 2 then target.pbFlinch(user)
		@battle.pbDisplay(_INTL("{1} flinched and couldn't move!", target.pbThis))
      end
    end
  end
  
#------------------------------------------------------------------------------
#Lucid Bloom
#------------------------------------------------------------------------------
class Battle::Move::LucidBloomHeal < Battle::Move
  def healingMove?; return true; end

  def pbMoveFailed?(user, targets)
    if @battle.allSameSideBattlers(user).none? { |b| b.canHeal? || b.status != :NONE }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return target.status == :NONE && !target.canHeal?
  end

  def pbEffectAgainstTarget(user, target)
	@battle.pbDisplay(_INTL("{1}'s meditative energy pulses outward!", user.pbThis))
    if target.canHeal?
      target.pbRecoverHP(target.totalhp / 3)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
    if target.status != :NONE
      old_status = target.status
      target.pbCureStatus(false)
      case old_status
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from sleep.", target.pbThis))
      when :POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", target.pbThis))
      when :BURN
        @battle.pbDisplay(_INTL("{1}'s burn was healed.", target.pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.", target.pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} was thawed out.", target.pbThis))
	  when :FROSTBITE
		@battle.pbDisplay(_INTL("{1} is no longer suffering from frostbite.", target.pbThis))
	  when :DROWSY
        @battle.pbDisplay(_INTL("{1} is no longer feeling drowsy.", target.pbThis))	  
	  when :FATIGUE
		@Battle.pbDisplay(_INTL("{1} is no longer fatigued.", target.pbThis))
	  when :WINDED
		@Battle.pbDisplay(_INTL("{1} is no longer feeling winded.", target.pbThis))
      when :VERTIGO
		@battle.pbDisplay(_INTL("{1} is no longer suffering from vertigo.", target.pbThis))
      when :SPLINTER
		@battle.pbDisplay(_INTL("{1}'s splinters have all been removed.", target.pbThis))
      when :PESTER
		@battle.pbDisplay(_INTL("{1} is no longer being pestered.", target.pbThis))
      when :SCARED
		@battle.pbDisplay(_INTL("{1} is no longer scared.", target.pbThis))
      when :BRITTLE
		@battle.pbDisplay(_INTL("{1} is no longer brittle.", target.pbThis))
      when :DRENCHED
		@battle.pbDisplay(_INTL("{1} has been dried off and is no longer drenched.", target.pbThis))
      when :ALLERGIES
		@battle.pbDisplay(_INTL("{1} no longer suffers from allergies.", target.pbThis))
      when :MIGRAINE
		@battle.pbDisplay(_INTL("{1}'s migraine has vanished.", target.pbThis))
      when :OPULENT
		@battle.pbDisplay(_INTL("{1} is no longer being greedy.", target.pbThis))
      when :BLINDED
		@battle.pbDisplay(_INTL("{1} can see again and is no longer blinded.", target.pbThis))
      when :IDOLIZE
		@battle.pbDisplay(_INTL("{1} is no longer infatuated.", target.pbThis))
      end
    end
  end
end

#------------------------------------------------------------------------------
#Rotburst
#------------------------------------------------------------------------------
class Battle::Move::ThirdTargetHPPoisonOrConfuse < Battle::Move::FixedDamageMove
  def pbFixedDamage(user, target); return (target.hp / 3.0).round; end   
	def pbAdditionalEffect(user, target)
		return if target.damageState.substitute
	case @battle.pbRandom(2)
    when 0 then target.pbConfuse if target.pbCanConfuse?(user, false, self)
    when 1 then target.pbPoison(user) if target.pbCanPoison?(user, false, self)
    end
   end
 end

#===============================================================================
# Decreases the target's accuracy by 1 stage.
#===============================================================================
class Battle::Move::LowerTargetAccuracy1Confuse < Battle::Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user, targets)
    failed = true
    targets.each do |b|
      next if !b.pbCanLowerStatStage?(:ACCURACY, user, self) &&
              !b.pbCanConfuse?(user, false, self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    if target.pbCanLowerStatStage?(:ACCURACY, user, self)
      target.pbLowerStatStage(:ACCURACY, 1, user)
    end
    target.pbConfuse if target.pbCanConfuse?(user, false, self)
  end
end

#===============================================================================
# User's Speed is used instead of user's Attack for this move's calculations.
# (Aerial Ace)
#===============================================================================
class Battle::Move::MySpeedIsMyAttack < Battle::Move
  def pbGetAttackStats(user, target)
    return user.speed, target.stages[:SPEED] + Battle::Battler::STAT_STAGE_MAXIMUM
  end
end