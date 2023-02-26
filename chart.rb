require "charty"
require "nokogiri" # actual webscraping i think. like bs4
require "net/http"
require "json" # JSON.parse()

# description/preview in google search has "college prep"?
# - "academy", "college prep", 
# first url that pops up has xxxusd.org? or isd.org? have to learn about districts

file = File.read("./worlds.json")
poi_hash = JSON.parse(file)
data = {
    prep: 0,
    norm: 0,
    name: "Normal vs Stinky Schools in WSD @ Berkeley 23"
}

poi_hash["prelimData"].each_key do |x| # key as parameter
    # if poi_hash["prelimData"][x] != poi_hash["prelimData"][0] then exit end
    school = x.split(' ')
    school= school[0, x.split(' ').length-1].join('+')

    url = "https://www.google.com/search?q=%s" % [school+"+school"]
    response = Net::HTTP.get_response(URI.parse(url))
    doc = Nokogiri::HTML(response.body)
    priv = "idk"
    # well nevermind this was some bullshit. the content overview cards
    # get constructed with javascript, so theyre no in the html im getting :(
    cont = doc.content
    if cont.include?("tuition") || 
        cont.include?("college prep") ||
        cont.include?("academy") then
        priv = "yeah"
        data[:prep]+=1
    end
    if cont.include?("school district") ||
        cont.include?("public school") then
        priv = "no"
        data[:norm]+=1
    end
end

puts data
# puts "%s, private? %s" % [school, priv]
chart = Charty::Plotter.new(:pyplot)
bar = charty.bar do
    series [data:prep], [1], label: "prep"
    series [data:norm], [1], label: "norm"
    label "yeah"
    label "nog"
    title data:title
end
bar.render("./chart.png")