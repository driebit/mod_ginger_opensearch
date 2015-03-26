-module(opensearch).

-export([
    search/2,
    search/5,
    parse_item_rss/1
]).

-include("zotonic.hrl").
-include_lib("xmerl/include/xmerl.hrl").

search(Url, SearchTerms) ->
    search(Url, SearchTerms, 100, 1, 1).

search(Url, SearchTerms, Count, StartIndex, StartPage) ->
    UrlParams = [ % count
        {searchTerms, SearchTerms},
        {count, Count},
        {startIndex, StartIndex},
        {startPage, StartPage}
    ],
    Response = request(Url, UrlParams),
    parse_response(Response).
    
%% @doc Execute request to OpenSearch endpoint
request(Endpoint, UrlParams) ->
    Url = http_utils:urlencode(Endpoint, UrlParams),
    case httpc:request(Url) of
        {ok, {
            {_HTTP, 200, _OK},
            _Headers,
            Body
        }} ->
            Body;
        Response ->
            Response
    end.
    
%% Parse an OpenSearch response 
parse_response(Response) ->
    {XmlRoot, _} = xmerl_scan:string(Response, [{space, normalize}]),
    ResultProps = [
        {link, ginger_xml:get_value("//channel/link", XmlRoot)},
        {totalResults, ginger_xml:get_value("//opensearch:totalResults", XmlRoot)},
        {startIndex, ginger_xml:get_value("//opensearch:startIndex", XmlRoot)},
        {itemsPerPage, ginger_xml:get_value("//opensearch:itemsPerPage", XmlRoot)}
    ],
    {ResultProps, xmerl_xpath:string("//item", XmlRoot)}.

parse_item_rss(Item) ->
    [
        {title, xml_utils:get_value("//title", Item)},
        {link, xml_utils:get_value("//link", Item)},
        {description, xml_utils:get_value("//description", Item)}
    ].
