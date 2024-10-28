using JuMP
using HiGHS

players = [
    "Tche95k", "CsPs4Player", "TooMaEU", "GoldIMc",
    "HydreTitanesque", "JxsteZarOwYT", "OkayWGN",
    "iSaucyEU", "Mowzxy", "PDIDDYPARTY2", "SnxxEZ",
    "Sinxurial", "zRxzmoL", "Phqla", "WhitossYTB"
]

days = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi"]

num_players = length(players)
num_days = length(days)
target_matches = 4  

availability = [
    [1, 0, 1, 1, 1],  # Tche95k
    [1, 1, 1, 1, 1],  # CsPs4Player
    [1, 1, 1, 1, 1],  # TooMaEU
    [1, 1, 1, 1, 1],  # GoldIMc
    [1, 1, 1, 1, 1],  # HydreTitanesque
    [1, 1, 1, 1, 1],  # JxsteZarOwYT
    [1, 1, 1, 1, 1],  # OkayWGN
    [1, 1, 1, 1, 1],  # iSaucyEU
    [1, 1, 1, 1, 1],  # Mowzxy
    [1, 1, 1, 1, 1],  # PDIDDYPARTY2
    [1, 1, 1, 1, 1],  # Sinxurial
    [0, 1, 1, 1, 0],  # SnxxEZ
    [1, 1, 1, 0, 1],  # zRxzmoL
    [0, 1, 0, 1, 1],  # Phqla
    [1, 0, 1, 1, 1]   # WhitossYTB
]

model = Model(HiGHS.Optimizer)

@variable(model, x[1:num_players, 1:num_players, 1:num_days], Bin)

for i in 1:num_players
    @constraint(model, sum(x[i, j, d] + x[j, i, d] for j in 1:num_players, d in 1:num_days) == target_matches)
end

for i in 1:num_players, d in 1:num_days
    @constraint(model, x[i, i, d] == 0)
end

for i in 1:num_players, j in 1:num_players, d in 1:num_days
    if availability[i][d] == 0 || availability[j][d] == 0
        @constraint(model, x[i, j, d] == 0)
    end
end

for d in 1:num_days
    @constraint(model, sum(x[i, j, d] for i in 1:num_players, j in 1:num_players) <= 14)
end

for i in 1:num_players, j in 1:num_players
    if i != j
        @constraint(model, sum(x[i, j, d] + x[j, i, d] for d in 1:num_days) <= 1)
    end
end

set_time_limit_sec(model, 60)
optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    println("Résultats des combats :")
    for d in 1:num_days
        println("Jour : ", days[d])
        for i in 1:num_players
            for j in 1:num_players
                if value(x[i, j, d]) > 0.5
                    println("  Combat : ", players[i], " vs ", players[j])
                end
            end
        end
    end
else
    println("Le modèle n'a pas de solution faisable ou optimale dans le délai imparti.")
end

println("\nNombre de combats par joueur : ", target_matches)
