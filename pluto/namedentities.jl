### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 42532742-7a85-11eb-2c05-093a5fce9597
begin
	using Pkg
	Pkg.activate(".")
	Pkg.instantiate
	
	using CitableTeiReaders
	using CitableText
	using EditorsRepo
	using EzXML
	
end


# ╔═╡ 26f4a106-7a85-11eb-143e-05619023aa71
md"Validate named entity tagging in HMT texts."

# ╔═╡ 8bf3ca3c-7a85-11eb-3ce0-cff2bdd01d4f
reporoot = "/Users/nsmith/Desktop/hmt/iliad3-2021"

# ╔═╡ 784cef0e-7a85-11eb-002e-19fd5549d2d5
function xmlcorpus(repo::EditingRepository)
    textcat = textcatalog(repo, "catalog.cex")
    online = filter(row -> row.online, textcat)
    corpora = []
    for txt in online
        urn = CtsUrn(txt.urn)
        reader = o2converter(repo, urn) |> Meta.parse |> eval
        xml = textforurn(repo, urn)	
        push!(corpora, reader(xml, urn))
    end
    composite_array(corpora)
end


# ╔═╡ 74d737da-7a85-11eb-253d-3f6e58aee02d
# Create a dictionary mapping URNs for 
# persNames to lists of  URNs for text passages.
function indexnames(c::CitableCorpus)
    dict = Dict()
    for cn in c.corpus
        xml = parsexml(cn.text)
        pns = findall("//persName", xml)
        for pn in pns
            if haskey(pn, "n")
                n = pn["n"]
                if haskey(dict, n)
                    #Already seen
                    prev = dict[n]
                    push!(dict, n => push!(prev, cn.urn))
                else
                    #First time
                    push!(dict, n => [cn.urn])
                end
            end 
        end
    end
    dict
end

# ╔═╡ ad691e40-7a85-11eb-1ada-f52791f3d92c
EditingRepository(reporoot, "editions", "dse", "config") |> xmlcorpus

# ╔═╡ Cell order:
# ╠═42532742-7a85-11eb-2c05-093a5fce9597
# ╟─26f4a106-7a85-11eb-143e-05619023aa71
# ╠═8bf3ca3c-7a85-11eb-3ce0-cff2bdd01d4f
# ╟─784cef0e-7a85-11eb-002e-19fd5549d2d5
# ╟─74d737da-7a85-11eb-253d-3f6e58aee02d
# ╠═ad691e40-7a85-11eb-1ada-f52791f3d92c
