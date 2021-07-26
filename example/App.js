import React, { useState, useCallback, useEffect } from 'react';
import { Text, SafeAreaView, TouchableOpacity, View } from 'react-native';
import CardVerify from 'react-native-cardverify';
import { CardView } from 'react-native-credit-card-input-view';

const StyledText = ({ color, bold, ...otherProps }) => (
  <Text
    {...otherProps}
    style={{
      fontSize: 18,
      margin: 10,
      textAlign: 'center',
      color: color || '#263547',
      fontWeight: bold ? '700' : '500',
    }}
  />
);

if (Platform.OS === 'ios') {
  CardVerify.setiOSVerifyViewStyle({
    'backButtonTintColor': '#000',

    'backgroundColor': '#FFC0CB',
    'backgroundColorOpacity': 0.5,
    
    'cardDetailExpiryTextColor': '#FFF',
    'cardDetailNameTextColor': '#FFF',
    'cardDetailNumberTextColor': '#FFF',

    'descriptionHeaderText': 'Scan Card',
    'descriptionHeaderTextColor': '#FFF',
    'descriptionHeaderTextFont': 'Avenir-Heavy',
    'descriptionHeaderTextSize': 30.0,

    'enableCameraPermissionText': "Enable your camera permissions",
    'enableCameraPermissionTextColor': '#000',
    'enableCameraPermissionTextFont': 'Avenir-LightOblique',
    'enableCameraPermissionTextSize': 20.0,

    'enableManualCardEntry': true,

    'instructionText': 'Please center your card in the middle',
    'instructionTextFont': 'Avenir-Light',
    'instructionTextColor': '#00ff00',
    'instructionTextSize': 20.0,

    'manualCardEntryText': 'Enter your card manually',
    'manualCardEntryTextColor': '#0000ff',
    'manualCardEntryTextFont': 'Avenir-BookOblique',
    'manualCardEntryTextSize': 25.0,

    'roiBorderColor': '#ff0000',
    'roiCornerRadius': 40.0,

    'torchButtonTintColor': '#000',
    'torchButtonPosition': 0,

    'wrongCardText': 'This is the wrong card'
  });
}

export default () => {
  const [compatible, setCompatible] = useState(null);
  const [card, setCard] = useState(null);
  const [recentAction, setRecentAction] = useState('none');

  const scanCard = useCallback(async () => {
    const { action, scanId, payload, canceledReason } = await CardVerify.scan(null, null, true);
    setRecentAction(action);
    if (action === 'scanned') {
      var issuer = payload.issuer || '??';
      if (issuer === 'MasterCard') {
        issuer = 'master-card';
      } else if (issuer === 'American Express') {
        issuer = 'american-express';
      } else {
        issuer = issuer.toLowerCase();
      }
      setCard({
        number: payload.number,
        expiryDay: payload.expiryDay || '',
        expiryMonth: payload.expiryMonth || '??',
        expiryYear: payload.expiryYear || '??',
        issuer: issuer,
        cvc: payload.cvc || '??',
        cardholderName: payload.cardholderName || '??',
        payloadVersion: payload.payloadVersion || 0,
        verificationPayload: payload.verificationPayload || ''
      });
    }

    if (action === 'canceled') {
      if (canceledReason === 'user_missing_card') {
        alert('User missing card');
      }

      if (canceledReason === 'user_canceled') {
        alert('User canceled scan');
      }

      if (canceledReason === 'camera_error') {
        alert('Camera error during scan');
      }

      if (canceledReason === 'fatal_error') {
        alert('Processing error during scan');
      }

      if (canceledReason === 'unknown') {
        alert('Unknown reason for scan cancellation');
      }
    }

    if (action === 'skipped') {
        alert('User skipped scanning for manual entry');
    }
  }, [setCard, setRecentAction]);

  const checkCompatible = useCallback(async () => {
    const isCompatible = await CardVerify.isSupportedAsync();
    setCompatible(isCompatible);
  }, [setCompatible]);

  useEffect(() => {
    checkCompatible();
  }, []);

  return (
    <SafeAreaView>
      <StyledText>
        Supported:{' '}
        {compatible == null ? 'Loading...' :
          compatible ?
            <StyledText color="#00B971">Yes</StyledText> :
            <StyledText color="#ff5345">No</StyledText>
        }
      </StyledText>
      {compatible &&
        <StyledText>Recent action: {recentAction}</StyledText>
      }
      {compatible &&
        <TouchableOpacity onPress={scanCard}>
          <StyledText bold>Scan card</StyledText>
        </TouchableOpacity>
      }
      {card &&
      <StyledText>Payload: {card.verificationPayload.length > 0 ? 'Ready' : 'Not Ready'}</StyledText>
      }
      {card &&
        <View style={{ margin: 20, flexDirection: 'row', flex: 1, justifyContent: 'center' }}>
          <CardView
            number={card.number}
            expiry={`${card.expiryMonth.padStart(2, '0')}/${card.expiryYear.slice(-2)}`}
            brand={card.issuer.toLowerCase()}
            name={card.cardholderName}
            cvc={card.cvc}
          />
        </View>
      }
    </SafeAreaView>
  );
};
