=begin

def ai_capture(unit)
  if unit can capture
    if currently capturing
      if can finish capture
        MAX OUT value
      else
        check surroundings
        if nothing vital is under enemy control (like HQ being captured)
          capture current building
        else
          consider attacking--lower the value, significantly so if moving required
        end
      end
    else
      if buildings in range to capture
        consider capturing--furthest away from current spot, highest value wins (HUGE VALUE)
      else
        check where the nearest building is
        pathfind to it
        if distance is impossible to traverse
          request transport
          move towards closest, required transport unit
        else
          move towards property
          request transport if far distance (more than 4 day walk)
        end
      end
    end
  end
end






if unit is capable of capturing
  if capturing
    finish capture
  else
    find best property to capture (furthest and highest influence-- HQ > bases > city)
    if no property in current range
      find next cloest property and save as goal
      consider attacking
    end
  end
end
if unit can attack
  if direct
    find enemy units in range to attack
    if enemy unit(s) found
      check if damage done to it versus counter is good
      if it is good, check unit inf at that spot
      
        (damage to other unit - damage received) + (cost of own units - cost of enemy units)
        + 20 for kill bonus
        + 10 for no damage received
        + 30 if none of the enemy units can attack your target
        - 20 if one of the enemy units can destroy your unit in one shot
        - 30 if damage received kills you
        Highest score wins
        
                                    :::::::Testing:::::::
        You: Tank and Mega
        Enemy: Recon blocking Artillery and Rocket
        
        Tank vs Recon
        (75 - 3) + (25000 - 21000)/1000 = 72 + 4 = 76
        
        Mega vs Recon
        (100 + 20 kill bonus) + (7000 - 21000)/1000 = 120 - 14 = 106
        
        Result: Attack with Mega first.
        
        But what if Tank was B-Copter? Rocket and Artillery are not a threat.
        
        Bcop vs Recon
        (75 - 6) + (25000 - 21000)/1000 + 30 perfect resist = 99 + 4 = 103
        
        Mega vs Recon
        (100 + 20) + (9000 - 21000)/1000 = 120 - 12 = 108
        
        Mega is still preferred due to kill bonus. If B-Cop did more damage, it
        would be wiser to lead with it first thanks to its immunity.
        
        Now what if two units do the same damage, but one costs more?
        (75 - 3) + (10 - 21) = 72 - 11 = 61
        (75 - 3) + (20 - 21) = 72 - 1  = 71
        In this case, the least expensive unit is preferred to attack the target.
        Which makes sense seeing that we can afford to lose a cheaper unit.

    



=end