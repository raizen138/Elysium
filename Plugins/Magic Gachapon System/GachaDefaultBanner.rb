def defaultBannerConfig
  config  = {
      "banner" => {
              "name" => "Banner De Respaldo",
              "bg" => "Graphics/Battlebacks/battlebgChampion",
              "rewards" => ["Graphics/Battlers/003","Graphics/Battlers/135","Graphics/Battlers/130"],
              "stars" => [5, 4, 5],
              "url" => nil,
              "descr" =>  "<ac><b>¡Increible Banner de prueba!</b></ac>\n¡Mira cuantos Pokémon! ¿No te parece super guay? ¡Puedes hacerte con todos dejándote el dinero en este banner!\n<ac>Disponible hasta el <c2=043c3aff>25-12-1995</c2>\n\n<u><b>Premios obtenibles:</b></u> \n*Bidoof 11.5%*\n*Goldeen 11.5%*\n*Ralts 11.5%*\n*Abra Especial 12%*\n*Pichu 28%*\n*Drowzee 28%*\n*Ekans 28%*\n*Eevee 6%*\n*Sandshrew 6%*\n*Dratini 4.5%*\n*Jolteon Especial 1.4%*\n*Max Éter 4.9%*\n*Kangskhan Especial 1.2%*\n*Gyarados Especial 0.9%*\n*Venusaur Especial 0.9%*\n*Master Ball 1.2%*</ac>\n\nNo nos hacemos responsables de los problemas que puedan surgir a partir de este juego del demonio. Úsese con responsabilidad."
              }
      }
  return config
end

def defaultBanner
  prob = rand(100)
  case prob
  when (0...35) #Tier 1 con un 35%
    pokes = [:BIDOOF, :GOLDEEN, :RALTS]
    result = pokes[rand(pokes.length)]
    pokeReward(PokeBattle_Pokemon.new(result,20,$Trainer),1)
  when (35...75) #Tier 2 con un 40%
    result = rand(10)
    if (5..7).include?(result)
      poke = PokeBattle_Pokemon.new(:ABRA,20,$Trainer)
      poke.ev[PBStats::SPATK]=236
      poke.ev[PBStats::SPDEF]=76
      poke.ev[PBStats::SPEED]=196
      poke.pbLearnMove(:PSYCHIC)
      poke.pbLearnMove(:DAZZLINGGLEAM)
      poke.pbLearnMove(:PROTECT)
      poke.pbLearnMove(:COUNTER)
      poke.calcStats
      pokeReward(poke,2)
    else
      pokes = [:PICHU, :DROWZEE, :EKANS] 
      result = pokes[rand(pokes.length)]
      pokeReward(PokeBattle_Pokemon.new(result,20,$Trainer),2)
    end
  when (75...90) #Tier 3 con un 15%
    result = rand(10)
    if (0..3).include?(result)
      poke = PokeBattle_Pokemon.new(:EEVEE,20,$Trainer)
      pokeReward(poke,3)
    elsif (4..7).include?(result)
      poke = PokeBattle_Pokemon.new(:SANDSHREW,20,$Trainer)
      pokeReward(poke,3)
    else
      poke = PokeBattle_Pokemon.new(:DRATINI,20,$Trainer)
      pokeReward(poke,3)
    end
  when (90...97) #Tier 4 con un 7%
    result = rand(10)
    if result > 7
      poke = PokeBattle_Pokemon.new(:JOLTEON,20,$Trainer)
      poke.iv[0]=31
      poke.iv[1]=31
      poke.iv[2]=31
      poke.iv[3]=31
      poke.iv[4]=31
      poke.iv[5]=31
      poke.pbLearnMove(:BITE)
      poke.pbLearnMove(:HIDDENPOWER)
      poke.pbLearnMove(:THUNDERSHOCK)
      poke.calcStats
      pokeReward(poke,4)
    else
      itemReward(:MAXETHER,4)
    end
  when (97...100) #Tier 5 con un 3%
    result = rand(10)
    if (0..3).include?(result)
      poke = PokeBattle_Pokemon.new(:KANGASKHAN,20,$Trainer)
      poke.ev[PBStats::HP]=212
      poke.ev[PBStats::ATTACK]=252
      poke.ev[PBStats::SPEED]=44
      poke.setItem(:LEFTOVERS)
      poke.setNature(:ADAMANT)
      poke.setAbility(0)
      poke.calcStats
      pokeReward(poke,5)
    elsif (4..5).include?(result)
      poke = PokeBattle_Pokemon.new(:GYARADOS,20,$Trainer)
      poke.ev[PBStats::HP]=68
      poke.ev[PBStats::ATTACK]=252
      poke.ev[PBStats::SPEED]=188
      poke.setItem(:LEFTOVERS)
      poke.setNature(:INTIMIDATE)
      poke.pbLearnMove(:DRAGONDANCE)
      poke.calcStats
      pokeReward(poke,5)
    elsif (6..7)
      poke = PokeBattle_Pokemon.new(:VENUSAUR,20,$Trainer)
      poke.ev[PBStats::HP]=252
      poke.ev[PBStats::DEFENSE]=84
      poke.ev[PBStats::SPDEF]=148
      poke.ev[PBStats::SPEED]=24
      poke.setNature(:CAREFUL)
      poke.setAbility(0)
      poke.calcStats
      pokeReward(poke,5)
    else
      itemReward(:MASTERBALL,5)
    end
  end
end