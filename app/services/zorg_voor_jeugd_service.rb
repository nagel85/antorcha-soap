class ZorgVoorJeugdService < ActionAntorcha::Base
  
  def organisatie_naw
    lookup = ZorgVoorJeugdAlias.lookup_alias(organization_id, username)
    lookup.organisatie_as_hash if lookup
  end 
  
  def body
    @params["nieuwe_signalering"].symbolize_keys!
  end
   
  def nieuwe_signalering
    signalering = ZorgVoorJeugd::Base.new organisatie_naw
    response = signalering.create body
    if response.success?
      reply :antwoordbericht_nieuwe_signalering do
        title "Gesignaleerd"
        body :nieuwe_signalering => {
          :status_code => response.status_code,
          :omschrijving => response.status_omschrijving,
          :signaal_uuid => response.signaal_uuid 
        }
      end
    elsif response.warning?
      reply :antwoordbericht_nieuwe_signalering do
        title "Gesignaleerd, echter met een waarschuwing"
        body :nieuwe_signalering => {
          :status_code => response.status_code,
          :omschrijving => response.status_omschrijving,
          :waarschuwing => true,
          :signaal_uuid => response.signaal_uuid 
        }
      end
    else
      reply :antwoordbericht_nieuwe_signalering do
        title "Signalering mislukt"
        body :nieuwe_signalering => {
          :status_code => response.status_code,
          :omschrijving => response.status_omschrijving,
          :failure => true
        }
      end
    end
  end
  
  def wijzig_signalering
  end
  
end