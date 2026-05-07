package com.yummydish.servlet;

import com.yummydish.model.*;
import com.yummydish.service.*;
import com.yummydish.util.FileStorageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

// ── Global model attributes injected into every JSP ──────────────
@org.springframework.web.bind.annotation.ControllerAdvice
class GlobalAdvice {
    @Value("${google.maps.api.key:}")    private String mapsKey;
    @Value("${firebase.api.key:}")       private String fbKey;
    @Value("${firebase.auth.domain:}")   private String fbDomain;
    @Value("${firebase.project.id:}")    private String fbProject;
    @Value("${google.oauth.client.id:}") private String googleClientId;
    @Value("${google.oauth.client.id:}") private String googleOAuthClientId;

    private final OfferService offerService;
    @Autowired GlobalAdvice(OfferService offerService) { this.offerService = offerService; }

    @ModelAttribute("googleMapsApiKey")      public String mapsKey()          { return mapsKey; }
    @ModelAttribute("googleOAuthClientId")   public String googleOAuthClientId() { return googleOAuthClientId; }
    @ModelAttribute("firebaseApiKey")     public String fbKey()     { return fbKey; }
    @ModelAttribute("firebaseAuthDomain") public String fbDomain()  { return fbDomain; }
    @ModelAttribute("firebaseProjectId")  public String fbProject() { return fbProject; }
    @ModelAttribute("activeOffers")       public List<Offer> offers(){ return offerService.getActive(); }
}
